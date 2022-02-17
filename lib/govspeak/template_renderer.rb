module Govspeak
  class TemplateRenderer
    attr_reader :template, :locale

    def initialize(template, locale)
      @template = template
      @locale = locale
    end

    def render(locals)
      template_binding = binding
      locals.each { |k, v| template_binding.local_variable_set(k, v) }
      erb = ERB.new(File.read(__dir__ + "/../templates/#{template}"))
      erb.result(template_binding)
    end

    def t(*args)
      options = args.last.is_a?(Hash) ? args.last.dup : {}
      key = args.shift
      I18n.t!(key, **options.merge(locale: locale))
    end

    def format_with_html_line_breaks(string)
      ERB::Util.html_escape(string || "").strip.gsub(/(?:\r?\n)/, "<br/>").html_safe
    end
  end
end
