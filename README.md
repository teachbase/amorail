[![Build Status](https://travis-ci.org/teachbase/amorail.svg?branch=master)](https://travis-ci.org/teachbase/amorail)

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

### Auth configuration

Amorail uses [anyway_config](https://github.com/palkan/anyway_config) for configuration, so you
can provide configuration parameters through env vars, seperate config file (`config/amorail.yml`) or `secrets.yml`.

Required params: **usermail**, **api_key** and **api_endpoint**.

Example:

```
# config/secrets.yml
development:
  ...
  amorail:
    usermail: 'amorail@test.com'
    api_key: '75742b166417fe32ae132282ce178cf6'
    api_endpoint: 'https://test.amocrm.ru'
```

For custom client params you should create a client manually before using Amorail functionality. It sets your params instead of params in anyway_config:  
```
# custom client
Amorail.client(usermail: 'user_email', api_key: "api_token", api_endpoint: "api_endpoint")

# reset custom client
Amorail.reset

```

### Running from console

You can try amorail in action from console ([PRY](https://github.com/pry/pry) is required to be installed):

```shell
# amorail gem directory
AMORAIL_USERMAIL=my_mail@test.com AMORAIL_API_KEY=my_key AMORAIL_API_ENDPOINT=my@amo.com bundle exec rake console
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

## Contributing

1. Fork it ( https://github.com/[my-github-username]/amorail/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
