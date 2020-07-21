require "test_helper"

class GovspeakLinkTest < Minitest::Test
  test "embedded link with link provided" do
    link = {
      content_id: "5572fee5-f38f-4641-8ffa-64fed9230ad4",
      url: "https://www.gov.uk/example",
      title: "Example page",
    }
    govspeak = "[embed:link:5572fee5-f38f-4641-8ffa-64fed9230ad4]"
    rendered = Govspeak::Document.new(govspeak, links: link).to_html
    expected = %r{<a href="https://www.gov.uk/example">Example page</a>}
    assert_match(expected, rendered)
  end

  test "embedded link with markdown title" do
    link = {
      content_id: "5572fee5-f38f-4641-8ffa-64fed9230ad4",
      url: "https://www.gov.uk/example",
      title: "**Example page**",
    }
    govspeak = "[embed:link:5572fee5-f38f-4641-8ffa-64fed9230ad4]"
    rendered = Govspeak::Document.new(govspeak, links: link).to_html
    expected = %r{<a href="https://www.gov.uk/example"><strong>Example page</strong></a>}
    assert_match(expected, rendered)
  end

  test "embedded link with external url" do
    link = {
      content_id: "5572fee5-f38f-4641-8ffa-64fed9230ad4",
      url: "https://www.example.com/",
      title: "Example website",
    }
    govspeak = "[embed:link:5572fee5-f38f-4641-8ffa-64fed9230ad4]"
    rendered = Govspeak::Document.new(govspeak, links: link).to_html
    expected = %r{<a rel="external" href="https://www.example.com/">Example website</a>}
    assert_match(expected, rendered)
  end
  test "embedded link with url not provided" do
    link = {
      content_id: "e510f1c1-4862-4333-889c-8d3acd443fbf",
      title: "Example website",
    }
    govspeak = "[embed:link:e510f1c1-4862-4333-889c-8d3acd443fbf]"
    rendered = Govspeak::Document.new(govspeak, links: link).to_html
    assert_match("Example website", rendered)
  end

  test "embedded link without link object" do
    govspeak = "[embed:link:0726637c-8c66-47ad-834a-d815cbf51e0e]"
    rendered = Govspeak::Document.new(govspeak).to_html
    assert_match("", rendered)
  end
end
