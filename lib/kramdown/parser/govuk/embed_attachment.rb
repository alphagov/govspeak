module Kramdown
  module Parser
    class Govuk
      EMBED_ATTACHMENT_PATTERN = /^\[Attachment:\s*(?<attachment_id>.*?)\s*\]/

      define_parser(:embed_attachment, EMBED_ATTACHMENT_PATTERN)

=begin
      extension("Attachment", /^\[Attachment:\s*(.*?)\s*\]/) do |attachment_id|
        next "" if attachments.none? { |a| a[:id] == attachment_id }

        %(<govspeak-embed-attachment id="#{attachment_id}"></govspeak-embed-attachment>)
      end
=end

      def parse_embed_attachment
        matches = @src.match(EMBED_ATTACHMENT_PATTERN)

        # it shouldn't be possible for matches to be nil since we're only in
        # #parse_embed_attachment because the pattern matched
        return if matches.nil?

        attachment_id = matches[:attachment_id]

        return if @attachments.none? { |a| a[:id] == attachment_id }
      end
    end
  end
end
