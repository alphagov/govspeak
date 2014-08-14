class Govspeak::HtmlValidator
  attr_reader :string

  def initialize(string, sanitization_options = {})
    @string = string.dup.force_encoding(Encoding::UTF_8)
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
    Govspeak::Document.new(string).to_html
  end
end
