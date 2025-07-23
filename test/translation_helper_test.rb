require "test_helper"

class TranslationHelperTest < Minitest::Test
  extend Minitest::Spec::DSL

  describe ".t_with_fallback" do
    before do
      I18n.expects(:available_locales).returns(%i[en cy])
      I18n
        .expects(:default_locale)
        .at_least_once
        .at_most(2)
        .returns(:en)
    end

    it "passes the provided key and options with a locale to I18n.t" do
      I18n.expects(:t).with(
        "whatever",
        a_translation_variable: "my favourite value",
        locale: instance_of(Symbol),
      )

      Govspeak::TranslationHelper.t_with_fallback(
        "whatever",
        a_translation_variable: "my favourite value",
      )
    end

    it "passes the default locale to I18n.t when matching the provided locale" do
      I18n.expects(:t).with("whatever", locale: :en)
      Govspeak::TranslationHelper.t_with_fallback("whatever", locale: :en)
    end

    it "passes a fallback translation using the default locale to I18n.t when the provided locale is supported but non-default" do
      I18n.expects(:t).with("whatever", locale: :en).returns("WHATEVER!")
      I18n.expects(:t).with("whatever", locale: :cy, default: "WHATEVER!")

      Govspeak::TranslationHelper.t_with_fallback("whatever", locale: :cy)
    end

    it "passes the default locale to I18n.t when the provided locale is unsupported" do
      I18n.expects(:t).with("whatever", locale: :en)
      Govspeak::TranslationHelper.t_with_fallback("whatever", locale: :yo)
    end

    it "passes the default locale to I18n.t when a locale is not provided" do
      I18n.expects(:t).with("whatever", locale: :en)
      Govspeak::TranslationHelper.t_with_fallback("whatever")
    end
  end

  describe ".supported_locales" do
    it "returns an array of metadata on supported locales" do
      assert_equal Govspeak::TranslationHelper.supported_locales, [
        { code: :ar, english_name: "Arabic", native_name: "العربيَّة" },
        { code: :be, english_name: "Belarusian", native_name: "Беларуская" },
        { code: :bg, english_name: "Bulgarian", native_name: "български" },
        { code: :cs, english_name: "Czech", native_name: "Čeština" },
        { code: :cy, english_name: "Welsh", native_name: "Cymraeg" },
        { code: :de, english_name: "German", native_name: "Deutsch" },
        { code: :el, english_name: "Greek", native_name: "Ελληνικά" },
        { code: :en, english_name: "English", native_name: "English" },
        {
          code: :"es-419",
          english_name: "Latin American Spanish",
          native_name: "Español de América Latina",
        },
        { code: :es, english_name: "Spanish", native_name: "Español" },
        { code: :et, english_name: "Estonian", native_name: "Eesti" },
        { code: :fa, english_name: "Persian", native_name: "فارسی" },
        { code: :fr, english_name: "French", native_name: "Français" },
        { code: :he, english_name: "Hebrew", native_name: "עברית" },
        { code: :hi, english_name: "Hindi", native_name: "हिंदी" },
        { code: :hu, english_name: "Hungarian", native_name: "Magyar" },
        { code: :hy, english_name: "Armenian", native_name: "Հայերեն" },
        {
          code: :id,
          english_name: "Indonesian",
          native_name: "Bahasa Indonesia",
        },
        { code: :it, english_name: "Italian", native_name: "Italiano" },
        { code: :ja, english_name: "Japanese", native_name: "日本語" },
        { code: :ko, english_name: "Korean", native_name: "한국어" },
        { code: :lt, english_name: "Lithuanian", native_name: "Lietuvių" },
        { code: :lv, english_name: "Latvian", native_name: "Latviešu" },
        { code: :pl, english_name: "Polish", native_name: "Polski" },
        { code: :ps, english_name: "Pashto", native_name: "پښتو" },
        { code: :pt, english_name: "Portuguese", native_name: "Português" },
        { code: :ro, english_name: "Romanian", native_name: "Română" },
        { code: :ru, english_name: "Russian", native_name: "Русский" },
        { code: :si, english_name: "Sinhala", native_name: "සිංහල" },
        { code: :sr, english_name: "Serbian", native_name: "Српски" },
        { code: :ta, english_name: "Tamil", native_name: "தமிழ்" },
        { code: :th, english_name: "Thai", native_name: "ไทย" },
        { code: :tr, english_name: "Turkish", native_name: "Türkçe" },
        { code: :uk, english_name: "Ukrainian", native_name: "Українська" },
        { code: :ur, english_name: "Urdu", native_name: "اردو" },
        { code: :uz, english_name: "Uzbek", native_name: "Oʻzbek" },
        { code: :vi, english_name: "Vietnamese", native_name: "Tiếng Việt" },
        {
          code: :"zh-hk",
          english_name: "Traditional Chinese (Hong Kong)",
          native_name: "繁體中文（香港）",
        },
        {
          code: :"zh-tw",
          english_name: "Traditional Chinese (Taiwan)",
          native_name: "繁體中文（臺灣）",
        },
        {
          code: :zh,
          english_name: "Simplified Chinese",
          native_name: "简体中文",
        },
      ]
    end
  end
end
