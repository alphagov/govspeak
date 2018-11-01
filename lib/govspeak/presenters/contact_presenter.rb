require 'active_support/core_ext/array'
require 'active_support/core_ext/hash'

module Govspeak
  class ContactPresenter
    attr_reader :contact

    def initialize(contact)
      @contact = ActiveSupport::HashWithIndifferentAccess.new(contact)
    end

    def content_id
      contact[:content_id]
    end

    def title
      contact[:title]
    end

    def description
      contact[:description]
    end

    def post_addresses
      contact.dig(:details, :post_addresses, [])
    end

    def email_addresses
      contact.dig(:details, :email_addresses) || []
    end

    def phone_numbers
      contact.dig(:details, :phone_numbers) || []
    end

    def contact_form_links
      contact.dig(:details, :contact_form_links) || []
    end
  end
end
