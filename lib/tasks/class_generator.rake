require 'amorail'

FOLDER_AMORAIL = Gem::Specification.find_by_name('amorail').gem_dir

namespace :class_generator do
  task :create do
    client = Amorail.client
    client.authorize
    
    contacts, companies, statuses = client.load_custom_fields
    
    contact_class = <<-EOS
module Amorail
  class AmoContact < Amorail::AmoEntity

    attr_accessor :url, :name, :company_name, :linked_leads_id, :email, :phone, :job_position, :id, :request_id


    def request_attributes
      {
        request: {
          contacts: {
            add: [
              {
                name: self.name,
                linked_leads_id: [self.linked_leads_id],
                company_name: self.company_name,
                custom_fields: [
                  {
                    id: #{contacts['POSITION']},
                    values: [{value: self.job_position}]
                  },
                  {
                    id: #{contacts['PHONE']},
                    values: [{value: self.phone, enum: 'MOB'}]
                  },
                  {
                    id: #{contacts['EMAIL']},
                    values: [{value: self.email, enum: 'WORK'}]
                  }
                ]
              }
            ]
          }
        }
      }
    end

    def reload_model(response)
      self.id = response["contacts"]["add"][0]["id"]
      self.request_id = response["contacts"]["add"][0]["request_id"]
    end
  end
end
EOS

company_class = <<-EOS
module Amorail
  class AmoCompany < Amorail::AmoEntity
    attr_accessor :url, :name, :linked_leads_id, :email, :phone, :address, :website, :id, :request_id, :company_name

    def request_attributes
      {
        request: {
          contacts: {
            add: [
              {
                name: self.name,
                linked_leads_id: [self.linked_leads_id],
                type: 'contact',
                company_name: self.company_name,
                custom_fields: [
                  {
                    id: #{companies['ADDRESS']},
                    values: [{value: self.address}]
                  },
                  {
                    id: #{companies['PHONE']},
                    values: [{value: self.phone, enum: 'WORK'}]
                  },
                  {
                    id: #{companies['EMAIL']},
                    values: [{value: self.email, enum: 'WORK'}]
                  },
                  {
                    id: #{companies['WEB']},
                    values: [{value: self.website}]
                  }
                ]
              }
            ]
          }
        }
      }
    end

    def reload_model(response)
      self.id = response["contacts"]["add"][0]["id"]
      self.request_id = response["contacts"]["add"][0]["request_id"]
    end
  end
end
EOS

lead_class = <<-EOS
module Amorail
  class AmoLead < Amorail::AmoEntity
    
    attr_accessor :url, :name, :price, :status_id, :tags, :id, :request_id

    def request_attributes
      {
        request: {
          leads: {
            add: [
              {
                name: self.name,
                tags: self.tags,
                price: self.price,
                status_id: #{statuses[0]['id']}
              }
            ]
          }
        }
      }
    end

    def reload_model(response)
      self.id = response["leads"]["add"][0]["id"]
      self.request_id = response["leads"]["add"][0]["request_id"]
    end
  end
end
EOS

task_class = <<-EOS
module Amorail
  class AmoTask < Amorail::AmoEntity
    attr_accessor :url, :name, :element_id, :element_type, :text, :complete_till, :task_type

    def request_attributes
      {
        request: {
          tasks: {
            add: [
              {
                text: self.text,
                element_id: self.element_id,
                element_type: self.element_type,
                task_type: self.task_type,
                complete_till: self.complete_till
              }
            ]
          }
        }
      }
    end 
  end
end
EOS
    
    puts_to_file(FOLDER_AMORAIL+'/lib/amorail/entities/contact.rb', contact_class)
    puts_to_file(FOLDER_AMORAIL+'/lib/amorail/entities/company.rb', company_class)
    puts_to_file(FOLDER_AMORAIL+'/lib/amorail/entities/lead.rb', lead_class)
    puts_to_file(FOLDER_AMORAIL+'/lib/amorail/entities/task.rb', task_class)
  end
end

def file_logger(file)
  if File.exists?(file)
    puts "[INFO] - Class file #{file} was generated"
  else
    puts "[ERR] - Class file #{file} wasn't generated!"
  end
end

def puts_to_file(file, string)
  contact_file_class = File.new(file, 'w')
  contact_file_class.puts string
  contact_file_class.close
  file_logger(file)
end