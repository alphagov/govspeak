require 'addressable/uri'
require 'sanitize'
require 'with_deep_merge'

class Govspeak::HtmlSanitizer
  include WithDeepMerge

  class ImageSourceWhitelister
    def initialize(allowed_image_hosts)
      @allowed_image_hosts = allowed_image_hosts
    end

    def call(sanitize_context)
      return unless sanitize_context[:node_name] == "img"

      node = sanitize_context[:node]
      image_uri = Addressable::URI.parse(node['src'])
      unless image_uri.relative? || @allowed_image_hosts.include?(image_uri.host)
        node.unlink # the node isn't sanitary. Remove it from the document.
      end
    end
  end

  class TableCellTextAlignWhitelister
    def call(sanitize_context)
      return unless ["td", "th"].include?(sanitize_context[:node_name])
      node = sanitize_context[:node]

      # Kramdown uses text-align to allow table cells to be aligned
      # http://kramdown.gettalong.org/quickref.html#tables
      if invalid_style_attribute?(node['style'])
        node.remove_attribute('style')
      end
    end

    def invalid_style_attribute?(style)
      style && !style.match(/^text-align:\s*(center|left|right)$/)
    end
  end

  def initialize(dirty_html, options = {})
    @dirty_html = dirty_html
    @allowed_image_hosts = options[:allowed_image_hosts]
  end

  def sanitize
    transformers = [TableCellTextAlignWhitelister.new]
    if @allowed_image_hosts && @allowed_image_hosts.any?
      transformers << ImageSourceWhitelister.new(@allowed_image_hosts)
    end
    Sanitize.clean(@dirty_html, sanitize_config.merge(transformers: transformers))
  end

  def sanitize_without_images
    config = sanitize_config
    config[:elements].delete('img')
    Sanitize.clean(@dirty_html, config)
  end

  def button_sanitize_config
    [
      "data-module",
      "data-tracking-code",
      "data-tracking-name"
    ]
  end

  def sanitize_config
    deep_merge(Sanitize::Config::RELAXED, {
      attributes: {
        :all => Sanitize::Config::RELAXED[:attributes][:all] + [ "id", "class", "role", "aria-label" ],
        "a"  => Sanitize::Config::RELAXED[:attributes]["a"] + ["rel"] + button_sanitize_config,
        "th"  => Sanitize::Config::RELAXED[:attributes]["th"] + [ "style" ],
        "td"  => Sanitize::Config::RELAXED[:attributes]["td"] + [ "style" ],
      },
      elements: Sanitize::Config::RELAXED[:elements] + [ "div", "span", "aside" ],
    })
  end
end
