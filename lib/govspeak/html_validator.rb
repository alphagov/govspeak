class Govspeak::HtmlValidator
  attr_reader :govspeak_string

  def initialize(govspeak_string, sanitization_options = {})
    @govspeak_string = govspeak_string.dup.force_encoding(Encoding::UTF_8)
    @sanitization_options = sanitization_options
  end

  def invalid?
    !valid?
  end

  def valid?
    dirty_html = govspeak_to_html
    clean_html = Govspeak::HtmlSanitizer.new(dirty_html, @sanitization_options).sanitize
    normalise_html(dirty_html) == normalise_html(clean_html)
  end

  # Make whitespace in html tags consistent
  def normalise_html(html)
    Nokogiri::HTML.parse(html).to_s
  end

  def govspeak_to_html
    Govspeak::Document.new(govspeak_string, sanitize: false).to_html
  end
end
