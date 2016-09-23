require "action_view"
require "money"

class AttachmentPresenter
  attr_reader :attachment
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::AssetTagHelper

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
    link(attachment_thumbnail, url, "aria-hidden=true class=#{attachment_class}")
  end

  def help_block_toggle_id
    "attachment-#{id}-accessibility-request"
  end

  def section_class
    attachment[:external?] ? "hosted-externally" : "embedded"
  end

  def mail_to(email_address, name, options = {})
    "<a href='mailto:#{email_address}?Subject=#{options[:subject]}&body=#{options[:body]}'>#{name}</a>"
  end

  def alternative_format_order_link
    attachment_info = []
    attachment_info << "  Title: #{title}"
    attachment_info << "  Original format: #{file_extension}"
    attachment_info << "  ISBN: #{attachment[:isbn]}" if attachment[:isbn]
    attachment_info << "  Unique reference: #{attachment[:unique_reference]}" if attachment[:unique_reference]
    attachment_info << "  Command paper number: #{attachment[:command_paper_number]}" if attachment[:command_paper_number]
    if attachment[:hoc_paper_number]
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
    <<-END
    Details of document required:

#{attachment_info.join("\n")}

Please tell us:

  1. What makes this format unsuitable for you?
  2. What format you would prefer?
   END
  end

  def alternative_format_contact_email
    "govuk-feedback@digital.cabinet-office.gov.uk"
  end

  def attachment_thumbnail
    if file_extension == "pdf"
      image_tag(attachment.file.thumbnail.url)
    elsif file_extension == "html"
      image_tag('pub-cover-html.png')
    elsif %w{doc docx odt}.include? file_extension
      image_tag('pub-cover-doc.png')
    elsif %w{xls xlsx ods csv}.include? file_extension
      image_tag('pub-cover-spreadsheet.png')
    else
      image_tag('pub-cover.png')
    end
  end

  def references
    references = []
    references << "ISBN: #{attachment[:isbn]}" if attachment[:isbn]
    references << "Unique reference: #{attachment[:unique_reference]}" if attachment[:unique_reference]
    references << "Command paper number: #{attachment[:command_paper_number]}" if attachment[:command_paper_number]
    references << "HC: #{attachment.hoc_paper_number} #{attachment[:parliamentary_session]}" if attachment[:hoc_paper_number]
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
    link(attachment[:preview_url], "<strong>Download #{file_extension.upcase}</strong>", number_to_human_size(attachment[:file_size]))
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
      attributes << content_tag(:span, pluralize(attachment[:number_of_pages], "page") , class: 'page-length') if attachment[:number_of_pages]
    end
    attributes.join(', ').html_safe
  end

  def preview_url
    url << '/preview'
  end

  MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE = "MS Word Document"
  MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE = "MS Excel Spreadsheet"
  MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE = "MS Powerpoint Presentation"

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
    attachment[:file_extension]
  end

  def hide_thumbnail?
    defined?(hide_thumbnail) && hide_thumbnail
  end

  def attachement_details
    return if previewable?
    link(title, url, title_link_options)
  end

  def title_link_options
    title_link_options = ''
    title_link_options << "rel=external" if attachment[:external?]
    title_link_options << "aria-describedby=#{help_block_id}" unless attachment[:accessible?]
  end

  def help_block_id
    "attachment-#{id}-accessibility-help"
  end

  def link(body, url, options={})
    <<-END
      <a href="#{url} #{options}">
        #{body}
      </a>
    END
  end
end
