# encoding: utf-8

require 'test_helper'
require 'ostruct'

class HCardPresenterTest < Minitest::Test
  def unindent(html)
    html.gsub(/^\s+/, '')
  end

  test "renders address in UK format" do
    assert_equal unindent(gb_addr), HCardPresenter.new(addr_fields, 'GB').render
  end

  test "renders address in Spanish format" do
    assert_equal unindent(es_addr), HCardPresenter.new(addr_fields, 'ES').render
  end

  test "renders address in Japanese format" do
    assert_equal unindent(jp_addr), HCardPresenter.new(addr_fields, 'JP').render
  end

  test "doesn't clobber address formats" do
    gb_format_before = HCardPresenter.address_formats['gb'].dup
    HCardPresenter.new(addr_fields, 'GB').render

    assert_equal unindent(gb_format_before), HCardPresenter.address_formats['gb']
  end

  test "blank properties do not render extra line breaks" do
    fields_without_region = addr_fields
    fields_without_region.delete('region')

    assert_equal unindent(addr_without_region), HCardPresenter.new(fields_without_region, 'GB').render
  end

  test "doesn't render a property when it's a blank string" do
    fields = addr_fields

    fields['region'] = ''
    assert_equal unindent(addr_without_region), HCardPresenter.new(fields, 'GB').render

    fields['region'] = '   '
    assert_equal unindent(addr_without_region), HCardPresenter.new(fields, 'GB').render
  end

  test 'uses html escaping on property values' do
    fields = addr_fields

    fields['region'] = 'UK & Channel Islands'
    assert_includes HCardPresenter.new(fields, 'GB').render, "UK &amp; Channel Islands"
  end

  test "it defaults to UK format" do
    assert_equal unindent(gb_addr), HCardPresenter.new(addr_fields, 'FUBAR').render
  end

  test "it builds from a Contact" do
    contact = OpenStruct.new(recipient: 'Recipient',
                             street_address: 'Street',
                             locality: 'Locality',
                             region: 'Region',
                             postal_code: 'Postcode',
                             country_name: 'Country',
                             country_code: 'ES')
    hcard = HCardPresenter.from_contact(contact)

    assert_equal unindent(es_addr), hcard.render
  end

  test "it leaves out the country name when building a GB contact" do
    contact = OpenStruct.new(recipient: 'Recipient',
                             street_address: 'Street',
                             locality: 'Locality',
                             region: 'Region',
                             postal_code: 'Postcode',
                             country_name: 'Country',
                             country_code: 'GB')
    hcard = HCardPresenter.from_contact(contact)

    assert_equal unindent(addr_without_country), hcard.render
  end

  def addr_fields
    { 'fn' => 'Recipient',
      'street-address' => 'Street',
      'postal-code' => 'Postcode',
      'locality' => 'Locality',
      'region' => 'Region',
      'country-name' => 'Country' }
  end

  def gb_addr
    <<-HTML
    <p class="adr">
    <span class="fn">Recipient</span><br />
    <span class="street-address">Street</span><br />
    <span class="locality">Locality</span><br />
    <span class="region">Region</span><br />
    <span class="postal-code">Postcode</span><br />
    <span class="country-name">Country</span>
    </p>
    HTML
  end

  def es_addr
    <<-HTML
    <p class="adr">
    <span class="fn">Recipient</span><br />
    <span class="street-address">Street</span><br />
    <span class="postal-code">Postcode</span> <span class="locality">Locality</span> <span class="region">Region</span><br />
    <span class="country-name">Country</span>
    </p>
    HTML
  end

  def jp_addr
    <<-HTML
    <p class="adr">
    〒<span class="postal-code">Postcode</span><br />
    <span class="region">Region</span><span class="locality">Locality</span><span class="street-address">Street</span><br />
    <span class="fn">Recipient</span><br />
    <span class="country-name">Country</span>
    </p>
    HTML
  end

  def addr_without_region
    <<-HTML
    <p class="adr">
    <span class="fn">Recipient</span><br />
    <span class="street-address">Street</span><br />
    <span class="locality">Locality</span><br />
    <span class="postal-code">Postcode</span><br />
    <span class="country-name">Country</span>
    </p>
    HTML
  end

  def addr_without_country
    <<-HTML
    <p class="adr">
    <span class="fn">Recipient</span><br />
    <span class="street-address">Street</span><br />
    <span class="locality">Locality</span><br />
    <span class="region">Region</span><br />
    <span class="postal-code">Postcode</span>
    </p>
    HTML
  end
end
