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
