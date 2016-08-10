# encoding: UTF-8

require 'test_helper'
require 'ostruct'

class GovspeakContactsTest < Minitest::Test

  def build_contact(attrs={})
    OpenStruct.new(
      has_postal_address?: attrs.fetch(:has_postal_address?, true),
      id: attrs.fetch(:id, 123456),
      content_id: attrs.fetch(:content_id, "4f3383e4-48a2-4461-a41d-f85ea8b89ba0"),
      title: attrs.fetch(:title, "Government Digital Service"),
      recipient: attrs.fetch(:recipient, ""),
      street_address: attrs.fetch(:street_address, "125 Kingsway"),
      postal_code: attrs.fetch(:postal_code, "WC2B 6NH"),
      locality: attrs.fetch(:locality, "Holborn"),
      region: attrs.fetch(:region, "London"),
      country_code: attrs.fetch(:country_code, "gb"),
      email: attrs.fetch(:email, "people@digital.cabinet-office.gov.uk"),
      contact_form_url: attrs.fetch(:contact_form_url, ""),
      contact_numbers: attrs.fetch(:contact_numbers,
                                   [OpenStruct.new(label: "helpdesk", number: "+4412345 67890")]),
      comments: attrs.fetch(:comments, ""),
      worldwide_organisation_path: attrs.fetch(:worldwide_organisation_path, nil),
    )
  end

  def compress_html(html)
    html.gsub(/[\n\r]+[\s]*/,'')
  end

  test "contact is rendered when present in options[:contacts]" do
    contact = build_contact
    govspeak = "[Contact:4f3383e4-48a2-4461-a41d-f85ea8b89ba0]"

    rendered = Govspeak::Document.new(govspeak, { contacts: [contact] }).to_html
    expected_html_output = %{
      <div id="contact_123456" class="contact postal-address">
        <div class="content">
          <h3>Government Digital Service</h3>
          <div class="vcard contact-inner">
            <p class="adr">
              <span class="street-address">125 Kingsway</span><br>
              <span class="locality">Holborn</span><br>
              <span class="region">London</span><br>
              <span class="postal-code">WC2B 6NH</span>
            </p>
            <div class="email-url-number">
              <p class="email">
                <span class="type">Email</span>
                <a href="mailto:people@digital.cabinet-office.gov.uk" class="email">people@digital.cabinet-office.gov.uk</a>
              </p>
              <p class="tel">
                <span class="type">helpdesk</span>
                +4412345 67890
              </p>
            </div>
          </div>
        </div>
      </div>
    }

    assert_equal(compress_html(expected_html_output), compress_html(rendered))
  end

  test "no contact is rendered when contact not present in options[:contacts]" do
    contact = build_contact(content_id: "19f06142-1b4a-47ce-b257-964badd0a5e2")
    govspeak = "[Contact:4f3383e4-48a2-4461-a41d-f85ea8b89ba0]"
    rendered = Govspeak::Document.new(govspeak, { contacts: [contact]}).to_html
    assert_match("", rendered)
  end

  test "no contact is rendered when no contacts are supplied" do
    rendered = Govspeak::Document.new("[Contact:4f3383e4-48a2-4461-a41d-f85ea8b89ba0]").to_html
    assert_match("", rendered)
  end

  test "contact with no postal address omits the address info" do
    contact = build_contact(has_postal_address?: false)
    govspeak = "[Contact:4f3383e4-48a2-4461-a41d-f85ea8b89ba0]"
    rendered = Govspeak::Document.new(govspeak, { contacts: [contact] }).to_html
    expected_html_output = %{
      <div id="contact_123456" class="contact">
        <div class="content">
          <h3>Government Digital Service</h3>
          <div class="vcard contact-inner">
            <div class="email-url-number">
              <p class="email">
                <span class="type">Email</span>
                <a href="mailto:people@digital.cabinet-office.gov.uk" class="email">people@digital.cabinet-office.gov.uk</a>
              </p>
              <p class="tel">
                <span class="type">helpdesk</span>
                +4412345 67890
              </p>
            </div>
          </div>
        </div>
      </div>
    }
    assert_equal(compress_html(expected_html_output), compress_html(rendered))
  end

  test "worldwide office contact renders worldwide organisation link" do
    contact = build_contact(worldwide_organisation_path: "/government/world/organisations/british-antarctic-territory")
    govspeak = "[Contact:4f3383e4-48a2-4461-a41d-f85ea8b89ba0]"
    rendered = Govspeak::Document.new(govspeak, { contacts: [contact] }).to_html
    organisation_link = %Q(<a href="/government/world/organisations/british-antarctic-territory">Access and opening times</a>)
    assert_match(organisation_link, rendered)
  end
end
