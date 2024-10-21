require "action_view"
require "htmlentities"

module Govspeak
  class EmbedPresenter
    include ActionView::Helpers::TagHelper

    attr_reader :embed

    def initialize(embed)
      @embed = ActiveSupport::HashWithIndifferentAccess.new(embed)
    end

    def content_id
      embed[:content_id]
    end

    def document_type
      embed[:document_type]
    end

    def render
      body = if document_type == "content_block_email_address"
               embed.dig(:details, :email_address)
             else
               embed[:title]
             end

      content_tag(:span, body, class: "embed embed-#{document_type}", id: "embed_#{content_id}")
    end
  end
end
