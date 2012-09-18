require "equivalent-xml"
require 'htmlentities'

class Govspeak::HtmlValidator
  attr_reader :string

  def initialize(string)
    @string = string
  end

  def invalid?
    !valid?
  end

  def valid?
    dirty_html = govspeak_to_html
    clean_html = Govspeak::HtmlSanitizer.new(dirty_html).sanitize
    EquivalentXml.equivalent?(normalize_entities(dirty_html),
                              normalize_entities(clean_html))
  end

  def govspeak_to_html
    Govspeak::Document.new(string).to_html
  end

  def normalize_entities(html)
    HTMLEntities.new.decode(html)
  end
end
