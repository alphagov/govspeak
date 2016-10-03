module Govspeak
  class HCardPresenter
    def self.from_contact(contact)
      new(contact_properties(contact), contact.country_code)
    end

    def self.contact_properties(contact)
      { 'fn' => contact.recipient,
        'street-address' => contact.street_address,
        'postal-code' => contact.postal_code,
        'locality' => contact.locality,
        'region' => contact.region,
        'country-name' => country_name(contact) }
    end

    def self.country_name(contact)
      contact.country_name unless contact.country_code == 'GB'
    end

    def self.property_keys
      ['fn', 'street-address', 'postal-code', 'locality', 'region', 'country-name']
    end

    def self.address_formats
      @address_formats ||= YAML.load_file('config/address_formats.yml')
    end

    attr_reader :properties, :country_code

    def initialize(properties, country_code)
      @properties = properties
      @country_code = country_code
    end

    def render
      "<p class=\"adr\">\n#{interpolate_address_template}\n</p>\n".html_safe
    end

    def interpolate_address_property(property_name)
      value = properties[property_name]

      if value.present?
        "<span class=\"#{property_name}\">#{ERB::Util.html_escape(value)}</span>"
      else
        ""
      end
    end

  private

    def interpolate_address_template
      address = address_template

      self.class.property_keys.each do |key|
        address.gsub!(/\{\{#{key}\}\}/, interpolate_address_property(key))
      end

      address.gsub(/^\n/, '')         # get  rid of blank lines
             .strip                   # get rid of any trailing whitespace
             .gsub(/\n/, "<br />\n")  # add break tags where appropriate
    end

    def address_template
      (self.class.address_formats[country_code.to_s.downcase] || default_format_string).dup
    end

    def default_format_string
      self.class.address_formats['gb']
    end
  end
end
