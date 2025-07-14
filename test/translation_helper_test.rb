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
end
