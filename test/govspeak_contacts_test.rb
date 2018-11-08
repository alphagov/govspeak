# encoding: UTF-8

require 'test_helper'

class GovspeakContactsTest < Minitest::Test
  def build_contact(attrs = {})
    {
      content_id: attrs.fetch(:content_id, "4f3383e4-48a2-4461-a41d-f85ea8b89ba0"),
      title: attrs.fetch(:title, "Government Digital Service"),
      description: attrs.fetch(:description, ""),
      details: {
        post_addresses: attrs.fetch(
          :post_addresses,
          [
            {
              title: "",
              street_address: "125 Kingsway",
              locality: "Holborn",
              region: "London",
              postal_code: "WC2B 6NH",
              world_location: "United Kingdom",
            }
          ]
        ),
        email_addresses: attrs.fetch(
          :email_addresses,
          [
            {
              title: "",
              email: "people@digital.cabinet-office.gov.uk",
            }
          ]
        ),
        phone_numbers: attrs.fetch(
          :phone_numbers,
          [
            {
              title: "helpdesk",
              number: "+4412345 67890",
            }
          ]
        ),
        contact_form_links: attrs.fetch(
          :contact_form_links,
          [
            {
              link: "https://www.gov.uk/contact"
            }
          ]
        )
      }
    }
  end

  def compress_html(html)
    html.gsub(/[\n\r]+[\s]*/, '')
  end

  test "contact is rendered when present in options[:contacts]" do
    contact = build_contact
    govspeak = "[Contact:4f3383e4-48a2-4461-a41d-f85ea8b89ba0]"

    rendered = Govspeak::Document.new(govspeak, contacts: [contact]).to_html
    expected_html_output = %{
      <div id="contact_4f3383e4-48a2-4461-a41d-f85ea8b89ba0" class="contact postal-address">
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
              <p class="contact_form_url">
                <span class="type">Contact form</span>
                <a href="https://www.gov.uk/contact">https://www.gov.uk/con...</a>
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
    rendered = Govspeak::Document.new(govspeak, contacts: [contact]).to_html
    assert_match("", rendered)
  end

  test "contact with no postal address omits the address info" do
    contact = build_contact(post_addresses: [])
    govspeak = "[Contact:4f3383e4-48a2-4461-a41d-f85ea8b89ba0]"
    rendered = Govspeak::Document.new(govspeak, contacts: [contact]).to_html
    expected_html_output = %{
      <div id="contact_4f3383e4-48a2-4461-a41d-f85ea8b89ba0" class="contact">
        <div class="content">
          <h3>Government Digital Service</h3>
          <div class="vcard contact-inner">
            <div class="email-url-number">
              <p class="email">
                <span class="type">Email</span>
                <a href="mailto:people@digital.cabinet-office.gov.uk" class="email">people@digital.cabinet-office.gov.uk</a>
              </p>
              <p class="contact_form_url">
                <span class="type">Contact form</span>
                <a href="https://www.gov.uk/contact">https://www.gov.uk/con...</a>
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

  test "contact with United Kingdom country address doesn't show the country" do
    contact = build_contact(post_addresses: [
      {
        street_address: "125 Kingsway",
        country_name: "United Kingdom",
      }
    ])
    govspeak = "[Contact:4f3383e4-48a2-4461-a41d-f85ea8b89ba0]"
    rendered = Govspeak::Document.new(govspeak, contacts: [contact]).to_html
    expected = %{
      <p class="adr">
        <span class="street-address">125 Kingsway</span>
      </p>
    }
    assert_match(compress_html(expected), compress_html(rendered))
  end

  test "contact with an empty postal address is not rendered" do
    contact = build_contact(post_addresses: [
      {
        street_address: "",
      }
    ])
    govspeak = "[Contact:4f3383e4-48a2-4461-a41d-f85ea8b89ba0]"
    rendered = Govspeak::Document.new(govspeak, contacts: [contact]).to_html
    refute_match(%{<p class="adr">}, compress_html(rendered))
  end

  test "contact with an empty email address is not rendered" do
    contact = build_contact(email_addresses: [
      {
        email: "",
      }
    ])
    govspeak = "[Contact:4f3383e4-48a2-4461-a41d-f85ea8b89ba0]"
    rendered = Govspeak::Document.new(govspeak, contacts: [contact]).to_html
    refute_match(%{<p class="email">}, compress_html(rendered))
  end

  test "contact with an empty contact form is not rendered" do
    contact = build_contact(contact_form_links: [
      {
        link: "",
      }
    ])
    govspeak = "[Contact:4f3383e4-48a2-4461-a41d-f85ea8b89ba0]"
    rendered = Govspeak::Document.new(govspeak, contacts: [contact]).to_html
    refute_match(%{<p class="contact_form_url">}, compress_html(rendered))
  end

  test "contact with an empty phone number is not rendered" do
    contact = build_contact(phone_numbers: [
      {
        number: "",
      }
    ])
    govspeak = "[Contact:4f3383e4-48a2-4461-a41d-f85ea8b89ba0]"
    rendered = Govspeak::Document.new(govspeak, contacts: [contact]).to_html
    refute_match(%{<p class="tel">}, compress_html(rendered))
  end

  test "it auto links text in the description" do
    contact = build_contact(description: "My description about https://www.gov.uk")

    govspeak = "[Contact:4f3383e4-48a2-4461-a41d-f85ea8b89ba0]"
    rendered = Govspeak::Document.new(govspeak, contacts: [contact]).to_html
    assert_match(%{<p class="comments">My description about <a href="https://www.gov.uk">https://www.gov.uk</a></p>},
                 compress_html(rendered))
  end
end
