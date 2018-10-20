module Amorail # :nodoc: all
  class Entity
    class InvalidRecord < ::Amorail::Error; end
    class NotPersisted < ::Amorail::Error; end

    def new_record?
      id.blank?
    end

    def persisted?
      !new_record?
    end

    def save
      return false unless valid?

      new_record? ? push('add') : push('update')
    end

    def save!
      save || fail(InvalidRecord)
    end

    def update(attrs = {})
      return false if new_record?

      merge_params(attrs)
      push('update')
    end

    def update!(attrs = {})
      update(attrs) || fail(NotPersisted)
    end

    def reload
      fail NotPersisted if id.nil?

      load_record(id)
    end

    private

    def extract_data_add(response)
      response.fetch('add').first
    end

    # Update response can have status 200 and contain errors.
    # In case of errors "update" key in a response is a Hash with "errors" key.
    # If there are no errors "update" key is an Array with entities attributes.
    def extract_data_update(response)
      case data = response.fetch('update')
      when Array
        data.first
      when Hash
        merge_errors(data)
        raise(InvalidRecord)
      end
    end

    def merge_errors(data)
      data.fetch("errors").each do |_, message|
        errors.add(:base, message)
      end
    end
  end
end
