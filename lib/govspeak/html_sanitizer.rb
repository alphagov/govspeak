require "addressable/uri"

class Govspeak::HtmlSanitizer
  class ImageSourceWhitelister
    def initialize(allowed_image_hosts)
      @allowed_image_hosts = allowed_image_hosts
    end

    def call(sanitize_context)
      return unless sanitize_context[:node_name] == "img"

      node = sanitize_context[:node]
      image_uri = Addressable::URI.parse(node["src"])
      unless image_uri.relative? || @allowed_image_hosts.include?(image_uri.host)
        node.unlink # the node isn't sanitary. Remove it from the document.
      end
    end
  end

  class TableCellTextAlignWhitelister
    def call(sanitize_context)
      return unless %w[td th].include?(sanitize_context[:node_name])

      node = sanitize_context[:node]

      # Kramdown uses text-align to allow table cells to be aligned
      # http://kramdown.gettalong.org/quickref.html#tables
      if invalid_style_attribute?(node["style"])
        node.remove_attribute("style")
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

  def sanitize(allowed_elements: [])
    transformers = [TableCellTextAlignWhitelister.new]
    if @allowed_image_hosts && @allowed_image_hosts.any?
      transformers << ImageSourceWhitelister.new(@allowed_image_hosts)
    end

    # It would be cleaner to move this `transformers` key into the `sanitize_config` method rather
    # than having to use Sanitize::Config.merge() twice in succession. However, `sanitize_config`
    # is a public method and it looks like other projects depend on it behaving the way it
    # currently does – i.e. to return Sanitize config without any transformers.
    # e.g. https://github.com/alphagov/hmrc-manuals-api/blob/4a83f78d0bb839520155623fd9b63b3b12a3b13a/app/validators/no_dangerous_html_in_text_fields_validator.rb#L44
    config_with_transformers = Sanitize::Config.merge(
      sanitize_config(allowed_elements: allowed_elements),
      transformers: transformers,
    )

    Sanitize.clean(@dirty_html, config_with_transformers)
  end

  def sanitize_config(allowed_elements: [])
    Sanitize::Config.merge(
      Sanitize::Config::RELAXED,
      elements: Sanitize::Config::RELAXED[:elements] + %w[govspeak-embed-attachment govspeak-embed-attachment-link svg path].concat(allowed_elements),
      attributes: {
        :all => Sanitize::Config::RELAXED[:attributes][:all] + %w[role aria-label],
        "a" => Sanitize::Config::RELAXED[:attributes]["a"] + [:data] + %w[draggable],
        "svg" => Sanitize::Config::RELAXED[:attributes][:all] + %w[xmlns width height viewbox focusable],
        "path" => Sanitize::Config::RELAXED[:attributes][:all] + %w[fill d],
        "div" => [:data],
        # @TODO  These style attributes can be removed once we've checked there
        # isn't hardcoded HTML in documents that uses them
        "th" => Sanitize::Config::RELAXED[:attributes]["th"] + %w[style],
        "td" => Sanitize::Config::RELAXED[:attributes]["td"] + %w[style],
        "govspeak-embed-attachment" => %w[content-id],
      },
    )
  end
end
