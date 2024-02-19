class Govspeak::HtmlValidator
  attr_reader :govspeak_string

  def initialize(govspeak_string, options = {})
    @govspeak_string = govspeak_string.dup.force_encoding(Encoding::UTF_8)
    @allowed_image_hosts = options[:allowed_image_hosts]
  end

  def invalid?
    !valid?
  end

  def valid?
    dirty_html = govspeak_to_html(sanitize: false)
    clean_html = govspeak_to_html(sanitize: true)
    normalise_html(dirty_html) == normalise_html(clean_html)
  end

private

  # Make whitespace in html tags consistent
  def normalise_html(html)
    Nokogiri::HTML5.fragment(html).to_s.gsub("\n", "")
  end

  def govspeak_to_html(sanitize:)
    Govspeak::Document.new(
      govspeak_string,
      sanitize:,
      allowed_image_hosts: @allowed_image_hosts,
    ).to_html
  end
end
