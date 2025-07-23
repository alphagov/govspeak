module Govspeak
  class TranslationHelper
    def self.t_with_fallback(key, **options)
      if I18n.available_locales.none?(options[:locale]&.to_sym)
        options[:locale] = I18n.default_locale
      end

      if options[:locale] != I18n.default_locale
        options[:default] = I18n.t(
          key,
          **options.merge(locale: I18n.default_locale),
        )
      end

      I18n.t(key, **options)
    end

    def self.supported_locales
      I18n.available_locales.map do |locale|
        {
          code: locale,
          english_name: I18n.t("english_name", locale:),
          native_name: I18n.t("native_name", locale:),
        }
      end
    end
  end
end
