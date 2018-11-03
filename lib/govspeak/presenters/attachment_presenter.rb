require "action_view"
require "money"
require "htmlentities"

module Govspeak
  class AttachmentPresenter
    attr_reader :attachment
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::TextHelper

    def initialize(attachment)
      @attachment = attachment
    end

    def id
      attachment[:id]
    end

    def order_url
      attachment[:order_url]
    end

    def opendocument?
      attachment[:opendocument?]
    end

    def url
      attachment[:url]
    end

    def external?
      attachment[:external?]
    end

    def price
      return unless attachment[:price]

      Money.from_amount(attachment[:price], 'GBP').format
    end

    def accessible?
      attachment[:accessible?]
    end

    def thumbnail_link
      return if hide_thumbnail?
      return if previewable?

      link(attachment_thumbnail, url, "aria-hidden" => "true", "class" => attachment_class)
    end

    def help_block_toggle_id
      "attachment-#{id}-accessibility-request"
    end

    def section_class
      attachment[:external?] ? "hosted-externally" : "embedded"
    end

    def mail_to(email_address, name, options = {})
      query_string = options.slice(:subject, :body).map { |k, v| "#{urlencode(k)}=#{urlencode(v)}" }.join("&")
      "<a href='mailto:#{encode(email_address)}?#{encode(query_string)}'>#{name}</a>"
    end

    def alternative_format_order_link
      attachment_info = []
      attachment_info << "  Title: #{title}"
      attachment_info << "  Original format: #{file_extension}" if file_extension.present?
      attachment_info << "  ISBN: #{attachment[:isbn]}" if attachment[:isbn].present?
      attachment_info << "  Unique reference: #{attachment[:unique_reference]}" if attachment[:unique_reference].present?
      attachment_info << "  Command paper number: #{attachment[:command_paper_number]}" if attachment[:command_paper_number].present?
      if attachment[:hoc_paper_number].present?
        attachment_info << "  House of Commons paper number: #{attachment[:hoc_paper_number]}"
        attachment_info << "  Parliamentary session: #{attachment[:parliamentary_session]}"
      end

      options = {
        subject: "Request for '#{title}' in an alternative format",
        body: body_for_mail(attachment_info)
      }

      mail_to(alternative_format_contact_email, alternative_format_contact_email, options)
    end

    def body_for_mail(attachment_info)
      <<~TEXT
        Details of document required:

        #{attachment_info.join("\n")}

        Please tell us:

          1. What makes this format unsuitable for you?
          2. What format you would prefer?
      TEXT
    end

    def alternative_format_contact_email
      "govuk-feedback@digital.cabinet-office.gov.uk"
    end

    # FIXME: usage of image_tag will cause these to render at /images/ which seems
    # very host dependent. I assume this will need links to static urls.
    def attachment_thumbnail
      if file_extension == "pdf" && attachment[:thumbnail_url]
        image_tag(attachment[:thumbnail_url])
      elsif file_extension == "html"
        image_tag('pub-cover-html.png')
      elsif %w{doc docx odt}.include?(file_extension)
        image_tag('pub-cover-doc.png')
      elsif %w{xls xlsx ods csv}.include?(file_extension)
        image_tag('pub-cover-spreadsheet.png')
      else
        image_tag('pub-cover.png')
      end
    end

    def reference
      ref = []
      if attachment[:isbn].present?
        ref << "ISBN " + content_tag(:span, attachment[:isbn], class: "isbn")
      end

      if attachment[:unique_reference].present?
        ref << content_tag(:span, attachment[:unique_reference], class: "unique_reference")
      end

      if attachment[:command_paper_number].present?
        ref << content_tag(:span, attachment[:command_paper_number], class: "command_paper_number")
      end

      if attachment[:hoc_paper_number].present?
        ref << content_tag(:span, "HC #{attachment[:hoc_paper_number]}", class: 'house_of_commons_paper_number') + ' ' +
          content_tag(:span, attachment[:parliamentary_session], class: 'parliamentary_session')
      end

      ref.join(', ').html_safe
    end

    # FIXME this has english in it so will cause problems if the locale is not en
    def references_for_title
      references = []
      references << "ISBN: #{attachment[:isbn]}" if attachment[:isbn].present?
      references << "Unique reference: #{attachment[:unique_reference]}" if attachment[:unique_reference].present?
      references << "Command paper number: #{attachment[:command_paper_number]}" if attachment[:command_paper_number].present?
      references << "HC: #{attachment[:hoc_paper_number]} #{attachment[:parliamentary_session]}" if attachment[:hoc_paper_number].present?
      prefix = references.size == 1 ? "and its reference" : "and its references"
      references.any? ? ", #{prefix} (" + references.join(", ") + ")" : ""
    end

    def references?
      !attachment[:isbn].to_s.empty? || !attachment[:unique_reference].to_s.empty? || !attachment[:command_paper_number].to_s.empty? || !attachment[:hoc_paper_number].to_s.empty?
    end

    def attachment_class
      attachment[:external?] ? "hosted-externally" : "embedded"
    end

    def unnumbered_paper?
      attachment[:unnumbered_command_paper?] || attachment[:unnumbered_hoc_paper?]
    end

    def unnumbered_command_paper?
      attachment[:unnumbered_command_paper?]
    end

    def download_link
      options = {}
      options[:title] = number_to_human_size(attachment[:file_size]) if attachment[:file_size].present?
      link("<strong>Download #{file_extension.upcase}</strong>", attachment[:url], options)
    end

    def attachment_attributes
      attributes = []
      if file_extension == "html"
        attributes << content_tag(:span, 'HTML', class: 'type')
      elsif attachment[:external?]
        attributes << content_tag(:span, url, class: 'url')
      else
        attributes << content_tag(:span, humanized_content_type(file_extension), class: 'type') if file_extension
        attributes << content_tag(:span, number_to_human_size(attachment[:file_size]), class: 'file-size') if attachment[:file_size]
        attributes << content_tag(:span, pluralize(attachment[:number_of_pages], "page"), class: 'page-length') if attachment[:number_of_pages]
      end
      attributes.join(', ').html_safe
    end

    def preview_url
      url + '/preview'
    end

    MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE = "MS Word Document".freeze
    MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE = "MS Excel Spreadsheet".freeze
    MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE = "MS Powerpoint Presentation".freeze

    def file_abbr_tag(abbr, title)
      content_tag(:abbr, abbr, title: title)
    end

    def humanized_content_type(file_extension)
      file_extension_vs_humanized_content_type = {
        "chm"  => file_abbr_tag('CHM', 'Microsoft Compiled HTML Help'),
        "csv"  => file_abbr_tag('CSV', 'Comma-separated Values'),
        "diff" => file_abbr_tag('DIFF', 'Plain text differences'),
        "doc"  => MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE,
        "docx" => MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE,
        "dot"  => file_abbr_tag('DOT', 'MS Word Document Template'),
        "dxf"  => file_abbr_tag('DXF', 'AutoCAD Drawing Exchange Format'),
        "eps"  => file_abbr_tag('EPS', 'Encapsulated PostScript'),
        "gif"  => file_abbr_tag('GIF', 'Graphics Interchange Format'),
        "gml"  => file_abbr_tag('GML', 'Geography Markup Language'),
        "html" => file_abbr_tag('HTML', 'Hypertext Markup Language'),
        "ics" => file_abbr_tag('ICS', 'iCalendar file'),
        "jpg"  => "JPEG",
        "odp"  => file_abbr_tag('ODP', 'OpenDocument Presentation'),
        "ods"  => file_abbr_tag('ODS', 'OpenDocument Spreadsheet'),
        "odt"  => file_abbr_tag('ODT', 'OpenDocument Text document'),
        "pdf"  => file_abbr_tag('PDF', 'Portable Document Format'),
        "png"  => file_abbr_tag('PNG', 'Portable Network Graphic'),
        "ppt"  => MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE,
        "pptx" => MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE,
        "ps"   => file_abbr_tag('PS', 'PostScript'),
        "rdf"  => file_abbr_tag('RDF', 'Resource Description Framework'),
        "rtf"  => file_abbr_tag('RTF', 'Rich Text Format'),
        "sch"  => file_abbr_tag('SCH', 'XML based Schematic'),
        "txt"  => "Plain text",
        "wsdl" => file_abbr_tag('WSDL', 'Web Services Description Language'),
        "xls"  => MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE,
        "xlsm" => file_abbr_tag('XLSM', 'MS Excel Macro-Enabled Workbook'),
        "xlsx" => MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE,
        "xlt"  => file_abbr_tag('XLT', 'MS Excel Spreadsheet Template'),
        "xsd"  => file_abbr_tag('XSD', 'XML Schema'),
        "xslt" => file_abbr_tag('XSLT', 'Extensible Stylesheet Language Transformation'),
        "zip"  => file_abbr_tag('ZIP', 'Zip archive'),
      }
      file_extension_vs_humanized_content_type.fetch(file_extension.to_s.downcase, '')
    end

    def previewable?
      file_extension == "csv"
    end

    def title
      attachment[:title]
    end

    def file_extension
      # Note: this is a separate parameter rather than being calculated from the
      # filename because at the time of writing not all apps were using the effects
      # of this field.
      attachment[:file_extension]
    end

    def hide_thumbnail?
      defined?(hide_thumbnail) && hide_thumbnail
    end

    def attachment_details
      return if previewable?

      link(title, url, title_link_options)
    end

    def title_link_options
      title_link_options = {}
      title_link_options["rel"] = "external" if attachment[:external?]
      title_link_options["aria-describedby"] = help_block_id unless attachment[:accessible?]
      title_link_options
    end

    def help_block_id
      "attachment-#{id}-accessibility-help"
    end

    def link(body, url, options = {})
      options_str = options.map { |k, v| %{#{encode(k)}="#{encode(v)}"} }.join(" ")
      %{<a href="#{encode(url)}" #{options_str}>#{body}</a>}
    end

  private

    def encode(text)
      HTMLEntities.new.encode(text)
    end

    def urlencode(text)
      ERB::Util.url_encode(text)
    end
  end
end
