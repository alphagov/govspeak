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
      image_uri = URI.parse(node['src'])
      unless image_uri.relative? || @allowed_image_hosts.include?(image_uri.host)
        node.unlink # the node isn't sanitary. Remove it from the document.
      end
    end
  end

  def initialize(dirty_html, options = {})
    @dirty_html = dirty_html
    @allowed_image_hosts = options[:allowed_image_hosts]
  end

  def sanitize
    transformers = []
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

  def sanitize_config
    deep_merge(Sanitize::Config::RELAXED, {
      attributes: {
        :all => Sanitize::Config::RELAXED[:attributes][:all] + [ "id", "class", "role", "aria-label" ],
        "a"  => Sanitize::Config::RELAXED[:attributes]["a"] + [ "rel" ],
      },
      elements: Sanitize::Config::RELAXED[:elements] + [ "div", "span" ],
    })
  end
end
