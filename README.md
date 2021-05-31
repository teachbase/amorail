[![Gem Version](https://badge.fury.io/rb/amorail.svg)](https://rubygems.org/gems/amorail) [![Build Status](https://travis-ci.org/teachbase/amorail.svg?branch=master)](https://travis-ci.org/teachbase/amorail)

# Amorail

AmoCRM client

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'amorail'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install amorail

## Usage

With Amorail you can manipulate the following AmoCRM entities: Companies, Contacts, Leads and Tasks.
We're triying to build simple AR-like interface.

### Store configuration

In order to configure a token store you should set up a store adapter in a following way: `Amorail.token_store = :redis, { redis_url: 'redis://127.0.0.1:6379/0' }` (options can be omitted). Currently supported stores are `:redis` and `:memory`. Memory adapter is used **by default**.

Here is a default configuration for Redis:

```ruby
Amorail.token_store = :redis, {
  redis_host: "127.0.0.1",
  redis_port: "6379",
  redis_db_name: "0"
}
```

You can also provide a Redis URL instead:

```ruby
Amorail.token_store = :redis, { redis_url: "redis://localhost:6397" }
```

**NOTE**: if `REDIS_URL` environment variable is set it is used automatically.

### Add custom store

To add custom store you need declare a class that implements the interface `AbstractStoreAdapter`.
For example `class FileStoreAdapter < Amorail::StoreAdapters::AbstractStoreAdapter`

The class must contain constructor `initialize(**options)` and **4 required methods**:

1. `fetch_access` — method that should return Hash with token data (**required keys:** `token`, `refresh_token` and `expiration`) or empty Hash (`{}`) if no value was received
2. `persist_access` — method that stores data in storage
3. `update_access` — method that updates existed token data in storage
4. `access_expired?` — method that returns `true` if token was expired otherwise `false`

### Auth configuration

Amorail uses [anyway_config](https://github.com/palkan/anyway_config) for configuration, so you
can provide configuration parameters through env vars, seperate config file (`config/amorail.yml`) or `secrets.yml`.

Required params: **client_id**, **client_secret** **code**, **redirect_uri** and **api_endpoint**.

An authorization **code** is required for the initial obtaining of a pair of access and refresh tokens. You can see it in the interface or through a Redirect URI if the authorization was run from the modal window for permissions. The lifespan of the code is 20 minutes. [More details](https://www.amocrm.com/developers/content/oauth/oauth/)

Example:

```
# config/secrets.yml
development:
  ...
  amorail:
    client_id: c0df457d-eacc-47cc-behb-3d8f962g4lbf
    client_secret: a36b564b64398d3e53004c12e4997eb340e32b18ee185389ddb409292ebc5ebae297a3eab96be4a9d38ecbf274d90bbb54a7e8f282f40d1b29e5c9b2e2e357a6
    code: a911ff963f58ea6c846901056114d37a14d2efa4d05ffb6ef0a8d60d32e5d6dae785bd317cbc9b0bd04261cb0cf9905af0cc32b5567c1eb84433328d08888f5c613608b822c1928272769ffd284b
    redirect_uri: https://example.ru
    api_endpoint: https://test.amocrm.ru
    redis_host: 127.0.0.1
    redis_port: 6379
    redis_db_name: 0
```

### Running from console

You can try amorail in action from console ([PRY](https://github.com/pry/pry) is required to be installed):

```shell
# amorail gem directory
AMORAIL_CLIENT_ID=integration_id AMORAIL_CLIENT_SECRET=secret_key AMORAIL_CODE=my_code AMORAIL_REDIRECT_URI=https://example.com AMORAIL_API_ENDPOINT=https://test.amocrm.ru bundle exec rake console
pry> Amorail.properties
# ... prints properties (custom_fields) data
pry> Amorail::Contact.find_by_query("test_contact")
# ... returns array of contacts which satisfy the query  
```

### Create new objects

Create Leads

```ruby
lead = Amorail::Lead.new(
  name:  "Example Lead",
  tags: "IT, Sales",
  price: 100,
  status_id: Amorail.properties.leads.statuses[
    Rails.application.secrets.amoparams['lead_status']
  ].id
)

lead.save!
```

Create Company

```ruby
company = Amorail::Company.new(
  name: "My company",
  phone: "222-111",
  email: "human@example.com"
)
company.linked_leads_id << lead.id
company.save!
```

Create Contact

```ruby
contact = Amorail::Contact.new(
  name: "Ivan Ivanov",
  linked_company_id: company.id,
  phone: "111-222",
  email: "ivan@example.com"
)

contact.linked_leads_id << lead.id
contact.save!
```

Create Task

```ruby
task = Amorail::Task.new(
  text: "Example task",
  lead: true,
  complete_till: Time.zone.today.end_of_day,
  task_type: Amorail.properties.tasks[Rails.application.secrets.amoparams['task_code']].id
)

# set up lead id
task.element_id = lead.id
# and save it
task.save!
```

You can find any object by id:

```ruby
  Amorail::Company.find(company_id)
```

Or using query:

```ruby
  Amorail::Company.find_by_query("vip")
```

Or using arbitrary params:

```ruby
  Amorail::Company.where(query: "test", limit_rows: 10)
```

Also you can update objects, e.g:

```ruby
company = Amorail::Company.find(company_id)
contact = Amorail::Contact.find(contact_id)

# like this
contact.linked_company_id = company.id
contact.save!

# or

contact.update(linked_company_id: company.id)
```

### Querying

Load by id

```ruby
Amorail::Contact.find(223) #=> #<Amorail::Contact ...>
```

Load many entites by array of ids

```ruby
Amorail::Contact.find_all(123, 124) #=> [#<Amorail::Contact ...>, ...]
```

Load by query

```ruby
Amorail::Contact.find_by_query("my_company") #=> [#<Amorail::Contact ...>, ...]
```


Load contacts associated with lead

```ruby
lead = Amorail::Lead.find(1)
lead.contacts #=> [#<Amorail::Contact ...>, ...]
```

Load company associated with contact

```ruby
contact = Amorail::Contact.find(1)
contact.company #=> #<Amorail::Company ...>
```

Load leads associated with contact

```ruby
contact = Amorail::Contact.find(1)
contact.leads #=> [#<Amorail::Lead ...>, ...]
```

Load contacts-leads pairs

```ruby
# Load all contact-leads pairs for contacts
Amorail::ContactLink.find_by_contacts(1, 2)

# Load all contact-leads pairs for leads
Amorail::ContactLink.find_by_leads(1, 2)
```

### Properties Configuration

AmoCRM is using "custom_fields" architecture,
to get all information for your account, you can
find properties and set up configuration manually in config/secrets.yml.

Note: response example in official documentation: 
      https://developers.amocrm.ru/rest_api/accounts_current.php

1) Get list of properties for your account

```
rake amorail:check
```
Rake task will returns information about properties.

### Multiple configurations

It is possible to use Amorail with multiple AmoCRM accounts. To do so use `Amorail.with_client` method,
which receive client params or client instance and a block to execute within custom context:

```ruby
Amorail.with_client(client_id: "my_id", client_secret: "my_secret", code: "my_code", api_endpoint: "https://my.acmocrm.ru", redirect_uri: "https://example.com") do
  # Client specific code here
end

# or using client instance
my_client = Amorail::Client.new(client_id: "my_id", client_secret: "my_secret", code: "my_code", api_endpoint: "https://my.acmocrm.ru", redirect_uri: "https://example.com")

Amorail.with_client(client) do
  ...
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/amorail/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Follow style guides (use Rubocop)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
