module Govspeak
  class HCardPresenter
    def self.address_formats
      @address_formats ||= YAML.load_file(
        File.expand_path('config/address_formats.yml', Govspeak.root)
      )
    end

    attr_reader :contact_address

    def initialize(contact_address)
      @contact_address = contact_address
    end

    def render
      "<p class=\"adr\">\n#{interpolate_address_template}\n</p>\n".html_safe
    end

    def interpolate_address_property(our_name, hcard_name)
      value = contact_address[our_name]

      if value.present?
        "<span class=\"#{hcard_name}\">#{ERB::Util.html_escape(value)}</span>"
      else
        ""
      end
    end

  private

    def interpolate_address_template
      address = address_template

      properties = {
        title: "fn",
        street_address: "street-address",
        locality: "locality",
        region: "region",
        postal_code: "postal-code",
        country_name: "country-name",
      }

      properties.each do |our_name, hcard_name|
        address.gsub!(/\{\{#{hcard_name}\}\}/, interpolate_address_property(our_name, hcard_name))
      end

      address.gsub(/^\n/, '')         # get  rid of blank lines
             .strip                   # get rid of any trailing whitespace
             .gsub(/\n/, "<br />\n")  # add break tags where appropriate
    end

    def address_template
      country_code = contact_address[:iso2_country_code].to_s.downcase
      (self.class.address_formats[country_code] || default_format_string).dup
    end

    def default_format_string
      self.class.address_formats['gb']
    end
  end
end
