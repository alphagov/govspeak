module Govspeak
  module TranslationHelper
    def self.t_with_fallback(key, **options)
      options[:locale] ||= I18n.default_locale

      if options[:locale] != I18n.default_locale
        options[:default] = I18n.t(
          key,
          **options.merge(locale: I18n.default_locale),
        )
      end

      I18n.t(key, **options)
    end
  end
end
