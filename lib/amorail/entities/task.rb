module Amorail
  class AmoTask < Amorail::AmoEntity
    attr_accessor :url, :name, :element_id, :element_type, :text, :complete_till, :task_type

    def request_attributes
      {
        request: {
          tasks: {
            add: [
              {
                text: text,
                element_id: element_id,
                element_type: element_type,
                task_type: task_type,
                complete_till: complete_till
              }
            ]
          }
        }
      }
    end 
  end
end
