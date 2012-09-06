require 'sanitize'

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
    clean_html = sanitize_html(dirty_html)
    normalise_html(dirty_html) == normalise_html(clean_html)
  end

  # Make whitespace in html tags consistent
  def normalise_html(html)
    Nokogiri::HTML.parse(html).to_s
  end

  def govspeak_to_html
    Govspeak::Document.new(string).to_html
  end

  def sanitize_html(dirty_html)
    Sanitize.clean(dirty_html, sanitize_config)
  end

  def sanitize_config
    config = Sanitize::Config::RELAXED.dup
    config[:attributes][:all].push("id", "class")
    config[:attributes]["a"].push("rel")
    config[:elements].push("div", "hr")
    config
  end
end
