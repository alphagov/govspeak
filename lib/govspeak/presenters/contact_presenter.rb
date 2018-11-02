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
      @post_addresses ||= begin
                            addresses = contact.dig(:details, :post_addresses) || []
                            filter_post_addresses(addresses)
                          end
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

  private

    def filter_post_addresses(addresses)
      addresses.each do |address|
        # A lot of the postal addresses published to the Publishing API have
        # a populated array of postal addresses but each field an empty string :-(
        address.delete_if do |key, value|
          # Not showing United Kingdom country is a "feature" lifted and shifted
          # from Whitehall:
          # https://github.com/alphagov/whitehall/blob/c67d53d80f9856549c2da1941a10dbb9170be494/lib/address_formatter/formatter.rb#L17
          (key == "world_location" && value.strip == "United Kingdom" || value == "")
        end
      end

      addresses.reject(&:empty?)
    end
  end
end
