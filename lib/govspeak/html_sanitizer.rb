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

  def initialize(dirty_html, options = {})
    @dirty_html = dirty_html
    @allowed_image_hosts = options[:allowed_image_hosts]
  end

  def sanitize(allowed_elements: [])
    transformers = []
    if @allowed_image_hosts && @allowed_image_hosts.any?
      transformers << ImageSourceWhitelister.new(@allowed_image_hosts)
    end

    # It would be cleaner to move this `transformers` key into the `sanitize_config` method rather
    # than having to use Sanitize::Config.merge() twice in succession. However, `sanitize_config`
    # is a public method and it looks like other projects depend on it behaving the way it
    # currently does – i.e. to return Sanitize config without any transformers.
    # e.g. https://github.com/alphagov/hmrc-manuals-api/blob/4a83f78d0bb839520155623fd9b63b3b12a3b13a/app/validators/no_dangerous_html_in_text_fields_validator.rb#L44
    config_with_transformers = Sanitize::Config.merge(
      sanitize_config(allowed_elements:),
      transformers:,
    )

    Sanitize.clean(@dirty_html, config_with_transformers)
  end

  def sanitize_config(allowed_elements: [])
    # We purposefully disable style elements which Sanitize::Config::RELAXED allows
    elements = Sanitize::Config::RELAXED[:elements] - %w[style] +
      %w[govspeak-embed-attachment govspeak-embed-attachment-link svg path].concat(allowed_elements)

    Sanitize::Config.merge(
      Sanitize::Config::RELAXED,
      elements:,
      attributes: {
        # We purposefully disable style attributes which Sanitize::Config::RELAXED allows
        :all => Sanitize::Config::RELAXED[:attributes][:all] + %w[role aria-label] - %w[style],
        "a" => Sanitize::Config::RELAXED[:attributes]["a"] + [:data] + %w[draggable],
        "svg" => %w[xmlns width height viewbox focusable],
        "path" => %w[fill d],
        "div" => [:data],
        "span" => [:data],
        # The style attributes are permitted here just for the ones Kramdown for table alignment
        # we replace them in a post processor.
        "th" => Sanitize::Config::RELAXED[:attributes]["th"] + %w[style],
        "td" => Sanitize::Config::RELAXED[:attributes]["td"] + %w[style],
        "govspeak-embed-attachment" => %w[content-id],
      },
      # The only styling we permit is text-align on table cells (which is the CSS kramdown
      # generates), we can therefore only allow this one CSS property
      css: { properties: %w[text-align] },
    )
  end
end
