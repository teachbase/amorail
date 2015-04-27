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
      if save
        true
      else
        fail InvalidRecord
      end
    end

    def update(attrs = {})
      return false if new_record?
      merge_params(attrs)
      push('update')
    end

    def update!(attrs = {})
      if update(attrs)
        true
      else
        fail NotPersisted
      end
    end

    def reload
      fail NotPersisted if id.nil?
      load_record(id)
    end

    private

    def extract_data_add(response)
      response.fetch('add').first
    end
  end
end
