module Amorail
  class AmoTask < Amorail::AmoEntity
    set_amo_name "tasks"
    attr_accessor :element_id, :element_type, :text,
                  :complete_till, :task_type

    validates :text, :element_id,
              :element_type, :complete_till,
              :task_type,
              presence: true

    validates :element_type, inclusion: 1..2

    def create_params
      {
        request: {
          tasks: {
            add: [
              {
                text: text,
                date_create: to_timestamp(date_create),
                last_modified: to_timestamp(last_modified),
                request_id: request_id,
                responsible_user_id: responsible_user_id,
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
