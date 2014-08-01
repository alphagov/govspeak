require 'sanitize'
require 'with_deep_merge'

class Govspeak::HtmlSanitizer
  include WithDeepMerge

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
    deep_merge(Sanitize::Config::RELAXED, {
      attributes: {
        :all => Sanitize::Config::RELAXED[:attributes][:all] + [ "id", "class" ],
        "a"  => Sanitize::Config::RELAXED[:attributes]["a"] + [ "rel" ],
      },
      elements: Sanitize::Config::RELAXED[:elements] + [ "div" ],
    })
  end
end
