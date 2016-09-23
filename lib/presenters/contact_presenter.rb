require 'active_support/core_ext/array'
require 'ostruct'

class ContactPresenter
  attr_reader :contact
  delegate :id, :content_id, :title, :recipient, :street_address, :postal_code,
    :locality, :region, :country_code, :country_name, :email, :contact_form_url,
    :comments, :worldwide_organisation_path, to: :contact

  def initialize(contact)
    @contact = OpenStruct.new(contact)
  end

  def contact_numbers
    Array.wrap(contact[:contact_numbers])
  end

  def has_postal_address?
    recipient.present? || street_address.present? || locality.present? ||
    region.present? || postal_code.present?
  end
end
