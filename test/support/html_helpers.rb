module HtmlHelpers
  def html_has_selector?(html_string, selector)
    return false if html_string.nil? || html_string.empty?

    raise "No selector specified" if selector.nil? || selector.empty?

    fragment = Nokogiri::HTML.fragment(html_string)
    fragment.css(selector).any?
  end
end
