require "action_view"
require "htmlentities"

module Govspeak
  class AttachmentPresenter
    attr_reader :attachment

    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::TextHelper

    def initialize(attachment)
      @attachment = attachment
    end

    def id
      attachment[:id]
    end

    def url
      attachment[:url]
    end

    def title
      attachment[:title]
    end

    def file_extension
      # NOTE: this is a separate parameter rather than being calculated from the
      # filename because at the time of writing not all apps were using the effects
      # of this field.
      attachment[:file_extension]
    end

    def attachment_attributes
      attributes = []
      if file_extension == "html"
        attributes << content_tag(:span, "HTML", class: "type")
      elsif attachment[:external?]
        attributes << content_tag(:span, url, class: "url")
      else
        attributes << content_tag(:span, humanized_content_type(file_extension), class: "type") if file_extension
        attributes << content_tag(:span, number_to_human_size(attachment[:file_size]), class: "file-size") if attachment[:file_size]
        attributes << content_tag(:span, pluralize(attachment[:number_of_pages], "page"), class: "page-length") if attachment[:number_of_pages]
      end
      attributes.join(", ").html_safe
    end

    MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE = "MS Word Document".freeze
    MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE = "MS Excel Spreadsheet".freeze
    MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE = "MS Powerpoint Presentation".freeze

    def file_abbr_tag(abbr, title)
      content_tag(:abbr, abbr, title: title)
    end

    def humanized_content_type(file_extension)
      file_extension_vs_humanized_content_type = {
        "chm" => file_abbr_tag("CHM", "Microsoft Compiled HTML Help"),
        "csv" => file_abbr_tag("CSV", "Comma-separated Values"),
        "diff" => file_abbr_tag("DIFF", "Plain text differences"),
        "doc" => MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE,
        "docx" => MS_WORD_DOCUMENT_HUMANIZED_CONTENT_TYPE,
        "dot" => file_abbr_tag("DOT", "MS Word Document Template"),
        "dxf" => file_abbr_tag("DXF", "AutoCAD Drawing Exchange Format"),
        "eps" => file_abbr_tag("EPS", "Encapsulated PostScript"),
        "gif" => file_abbr_tag("GIF", "Graphics Interchange Format"),
        "gml" => file_abbr_tag("GML", "Geography Markup Language"),
        "html" => file_abbr_tag("HTML", "Hypertext Markup Language"),
        "ics" => file_abbr_tag("ICS", "iCalendar file"),
        "jpg" => "JPEG",
        "odp" => file_abbr_tag("ODP", "OpenDocument Presentation"),
        "ods" => file_abbr_tag("ODS", "OpenDocument Spreadsheet"),
        "odt" => file_abbr_tag("ODT", "OpenDocument Text document"),
        "pdf" => file_abbr_tag("PDF", "Portable Document Format"),
        "png" => file_abbr_tag("PNG", "Portable Network Graphic"),
        "ppt" => MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE,
        "pptx" => MS_POWERPOINT_PRESENTATION_HUMANIZED_CONTENT_TYPE,
        "ps" => file_abbr_tag("PS", "PostScript"),
        "rdf" => file_abbr_tag("RDF", "Resource Description Framework"),
        "rtf" => file_abbr_tag("RTF", "Rich Text Format"),
        "sch" => file_abbr_tag("SCH", "XML based Schematic"),
        "txt" => "Plain text",
        "wsdl" => file_abbr_tag("WSDL", "Web Services Description Language"),
        "xls" => MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE,
        "xlsm" => file_abbr_tag("XLSM", "MS Excel Macro-Enabled Workbook"),
        "xlsx" => MS_EXCEL_SPREADSHEET_HUMANIZED_CONTENT_TYPE,
        "xlt" => file_abbr_tag("XLT", "MS Excel Spreadsheet Template"),
        "xsd" => file_abbr_tag("XSD", "XML Schema"),
        "xslt" => file_abbr_tag("XSLT", "Extensible Stylesheet Language Transformation"),
        "zip" => file_abbr_tag("ZIP", "Zip archive"),
      }
      file_extension_vs_humanized_content_type.fetch(file_extension.to_s.downcase, "")
    end

    def link(body, url, options = {})
      options_str = options.map { |k, v| %(#{encode(k)}="#{encode(v)}") }.join(" ")
      %(<a href="#{encode(url)}" #{options_str}>#{body}</a>)
    end

  private

    def encode(text)
      HTMLEntities.new.encode(text)
    end
  end
end
