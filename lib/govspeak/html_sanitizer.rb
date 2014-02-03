require 'sanitize'

class Govspeak::HtmlSanitizer
  def initialize(dirty_html)
    @dirty_html = dirty_html
  end

  def sanitize
    Sanitize.clean(@dirty_html, sanitize_config)
  end

  def sanitize_without_images
    config = sanitize_config
    config[:elements].delete('img')
    Sanitize.clean(@dirty_html, config)
  end

  def sanitize_config
    config = Sanitize::Config::RELAXED.dup
    config[:attributes][:all].push("id", "class")
    config[:attributes]["a"].push("rel")
    config[:elements].push("div", "hr")
    config
  end
end