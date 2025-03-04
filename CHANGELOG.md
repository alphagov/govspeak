# Changelog

## 10.1.0

* Allow acronyms/abbreviations in steps ([#387](https://github.com/alphagov/govspeak/pull/387)).
* Add GA4 indexes to attachments that render a details component ([#385](https://github.com/alphagov/govspeak/pull/385))

## 10.0.1

* Update dependencies

## 10.0.0

* Drop support for Ruby <3.2
* Drop support for govuk_publishing_components <43.0.0

## 9.0.0

* Remove Advisory component ([#357](https://github.com/alphagov/govspeak/pull/357))

## 8.8.3

* Update dependencies (actionview < 8.0.2, sanitize < 8, rubocop-govuk = 5.0.7)

## 8.8.2

* Fix a bug where headings were no longer rendering inside example boxes ([#374](https://github.com/alphagov/govspeak/pull/374))

## 8.8.1

* Update dependencies

## 8.8.0

* Strip trailing backslashes from the lines of an address ([#371](https://github.com/alphagov/govspeak/pull/371))
* When replacing line breaks with "&lt;br&gt;"s in the parsing of address blocks,
replace the whole "\r\n" line break and not just the "\n" character ([#371](https://github.com/alphagov/govspeak/pull/371))
* Only strip a leading line break from an address block, not just any old first
occurrence of a line break ([#371](https://github.com/alphagov/govspeak/pull/371))
* Strip trailing whitespace from the lines of an address ([#371](https://github.com/alphagov/govspeak/pull/371))

## 8.7.0

* Allow data attributes in spans ([#364](https://github.com/alphagov/govspeak/pull/364))

## 8.6.1

* Update dependencies

## 8.6.0

* Remove embed functionality ([#358](https://github.com/alphagov/govspeak/pull/358))

## 8.5.1

* Rename embed-related code to `content block`
* Do not attempt to parse embed codes if `content_blocks` option is missing

## 8.5.0

* Support embeds in Govspeak

## 8.4.1

* Do not pin version of govuk_publishing_components

## 8.4.0

* Drop support for Ruby 3.0. The minimum required Ruby version is now 3.1.4.
* Add support for Ruby 3.3.
* Allow acronyms within example blocks.
* Allow tables within example blocks.
* Allow acronyms within address blocks.

## 8.3.4

* Fix tables within call to action component ([#306](https://github.com/alphagov/govspeak/pull/306))

## 8.3.3

* Fix single line formatting of call to action component ([#302](https://github.com/alphagov/govspeak/pull/302))

## 8.3.2

* Various bug fixes related to legislative list components ([#298](https://github.com/alphagov/govspeak/pull/298))

## 8.3.1

* Bug fixes related to block elements in call to action and legislative list components ([#293](https://github.com/alphagov/govspeak/pull/293))

## 8.3.0

* Various bug fixes related to abbreviations in call to action and legislative list components ([#291](https://github.com/alphagov/govspeak/pull/291))

## 8.2.1

* Prevent user error when incorrectly formatted footnotes are added to HTML attachments ([#287](https://github.com/alphagov/govspeak/pull/287))

## 8.2.0

* Reintroduce support for acronyms in Call To Action blocks and in Legislative Lists ([#285](https://github.com/alphagov/govspeak/pull/285))

## 8.1.0

* Allow attachment links wtihin numbered lists ([#283](https://github.com/alphagov/govspeak/pull/283))

## 8.0.1

* Add margin-bottom to embedded attachments ([#281](https://github.com/alphagov/govspeak/pull/281))

## 8.0.0

* BREAKING: HTML style attribute and style element, which were never supposed to be available, are forbidden. [#279](https://github.com/alphagov/govspeak/pull/279)

## 7.1.1

* Make image and attachment embedding syntax more consistent [#274](https://github.com/alphagov/govspeak/pull/274)

## 7.1.0

* Drop support for Ruby 2.7 [#272](https://github.com/alphagov/govspeak/pull/272)
* Replace inline style attributes in td/th elements with classes [#268](https://github.com/alphagov/govspeak/pull/268)

## 7.0.2

* Fix for abbreviations nested in button. [#267](https://github.com/alphagov/govspeak/pull/267)

## 7.0.1

* Govspeak was stripping superscript from markdown when it shouldn't have. [#264](https://github.com/alphagov/govspeak/pull/264)

## 7.0.0

* BREAKING CHANGE Remove `PriorityList`, the `PrimaryList` JS module to render the priority list on the frontend is to be removed [#249](https://github.com/alphagov/govspeak/pull/249)

## 6.8.4

* Fix bug where inconsistent linebreaks trigger validations [#250](https://github.com/alphagov/govspeak/pull/250)

## 6.8.3

* Require Kramdown minimum version of 2.3.1 to avoid CVE-2021-28834 [#246](https://github.com/alphagov/govspeak/pull/246)

## 6.8.2

* Fix footnote numbering [#239](https://github.com/alphagov/govspeak/pull/239)

## 6.8.1

* Fix a bug which resulted in validation errors on 'Start Button' elements [#237](https://github.com/alphagov/govspeak/pull/237)

## 6.8.0

* Drop support for Ruby 2.6 which reaches End of Life (EOL) on 31/03/2022
* Add support for Rails 7 by loosening the version constraint on `activeview` gem
* Fix deprecation notices caused by the bump in Ruby version

## 6.7.8

* Fixes bug which reverts acronyms from being converted into abbr tags [#229](https://github.com/alphagov/govspeak/pull/229)

## 6.7.7

* Fix broken HTML in CTA extension. [#226](https://github.com/alphagov/govspeak/pull/226)

## 6.7.6

* Add draggable false to button markup and validation [#224](https://github.com/alphagov/govspeak/pull/224)

## 6.7.5

* Fix footnotes in call-to-action boxes [222](https://github.com/alphagov/govspeak/pull/222)

## 6.7.4

* Remove Nokogumbo dependency to [resolve warning](https://github.com/sparklemotion/nokogiri/issues/2205) [220](https://github.com/alphagov/govspeak/pull/220)

## 6.7.3

* Fix regex for footnotes in legislative lists [218](https://github.com/alphagov/govspeak/pull/218)

## 6.7.2

* Minimum Ruby version specified at 2.6 [215](https://github.com/alphagov/govspeak/pull/215)
* Fix footnotes in legislative lists [216](https://github.com/alphagov/govspeak/pull/216)

## 6.7.1

* Update failing test [212](https://github.com/alphagov/govspeak/pull/212)
* Fix stats headline HTML semantics [213](https://github.com/alphagov/govspeak/pull/213)

## 6.7.0

* Update heading & docs [#206](https://github.com/alphagov/govspeak/pull/206)

## 6.6.0

* Allow passed elements to be relaxed from sanitization [#203](https://github.com/alphagov/govspeak/pull/203)

## 6.5.11

* Fix issue rendering $CTA blocks before $C (PR#202)

## 6.5.10

* Be optimistic in versions of govuk_publishing_components and i18n allowed (PR#200)

## 6.5.9

* Adjust footnote markup to accommodate multiple references (PR#198)

## 6.5.8

* Customise footnote markup for accessibility (PR#192)

## 6.5.7

* Update GOV.UK Publishing components to version to 23.0.0 or greater

## 6.5.6

* Update Kramdown version to 2.3.0 or greater

## 6.5.5

* Prevent links in table headers being stripped (PR#187)

## 6.5.4

* Require Sanitize to be at least 5.2.1 due to https://nvd.nist.gov/vuln/detail/CVE-2020-4054

## 6.5.3

* Use button component for buttons (PR#176)

## 6.5.2

* Allow `data` attributes on `div` tags (PR#173)

## 6.5.1

* Change unicode testing characters after external gem change
* Move from govuk-lint to rubocop-govuk
* Allow version 6 of actionview

## 6.5.0

* Allow data attributes on links

## 6.4.0

* Add table heading syntax that allows a table cell outside of `thead` to be marked as a table heading with a scope of row. (PR#161)

## 6.3.0

* Unicode characters forbidden in HTML are stripped from input
* Validation is now more lenient for HTML input

## 6.2.1

* Update warning callout label text from 'Help' to 'Warning'

## 6.2.0

* Remove experimental status on `AttachementLink:attachment-id` and `Attachement:attachment-id`
* Deprecate `embed:attachments:inline:content-id`

## 6.1.1

* Fix wrapping `AttachmentLink:attachment-id` in a paragraph when used inline

## 6.1.0

* Remove `[embed:attachments:content-id]` this isn't used by any apps and has never worked
* Add dependency on govuk_publishing_components
* Add new `AttachementLink:attachment-id` extension and mark as experimental
* Add new `Attachement:attachment-id` extension and mark as experimental
* Blockquote quote remover is now more forgiving to spaces before or after quote characters

## 6.0.0

* BREAKING CHANGE: Input is sanitized by default, to use unsafe HTML initialize with a sanitize option of false
* Allow sanitize option on remove invalid HTML from source input
* BREAKING CHANGE: Remove `to_sanitized_html` method in favour of `sanitize` option on initialize
* BREAKING CHANGE: Remove `to_sanitized_html_without_images` as no apps use this anymore
* BREAKING CHANGE: Remove CLI usage

## 5.9.1

* Don't render `[Image: {file-name}]` within a paragraph to avoid invalid HTML

## 5.9.0

* Add image credits to embedded images

## 5.8.0

* Add new `Image:image-id` extension and deprecate `embed:attachments:image:content-id`

## 5.7.1

* Include locale, config and asset files in the gem distribution

## 5.7.0

* Update ActionView to 5.x
* Fix translation files not loading when gem is used in an app
* Change the data inputted into Contacts to match contacts schema [#130](https://github.com/alphagov/govspeak/pull/130)

## 5.6.0

* Update sanitize version to 4.6.x [#127](https://github.com/alphagov/govspeak/issues/127)

## 5.5.0

* Ignore links with blank or missing `href`s when extracting links from a document with `Govspeak::Document#extracted_links` [#124](https://github.com/alphagov/govspeak/pull/124)

## 5.4.0

* Add an optional `website_root` argument to `Govspeak::Document#extracted_links` in order to get all links as fully qualified URLs [#122](https://github.com/alphagov/govspeak/pull/122)

## 5.3.0

* Add a link extraction class for finding links in documents [#120](https://github.com/alphagov/govspeak/pull/120)

## 5.2.2

* Fix rendering buttons with inconsistent linebreaks seen in publishing [#118](https://github.com/alphagov/govspeak/pull/118)

## 5.2.1

* Fix validation to make sure buttons are considered valid
* Only allow buttons to be used on new lines, not when indented or inline within text (useful for guides) [#116](https://github.com/alphagov/govspeak/pull/116)

## 5.2.0

* Add button component for govspeak [#114](https://github.com/alphagov/govspeak/pull/114) see README for usage

## 5.1.0

* Update Kramdown version to 1.15.0

## 5.0.3

* Fix matching links/attachments/contacts by regex to use equality [#105](https://github.com/alphagov/govspeak/pull/105)

## 5.0.2

* Loosen ActionView dependency to allow use with Rails
5 [#99](https://github.com/alphagov/govspeak/pull/99)

## 5.0.1

* Move presenters into the Govspeak namespace [#93](https://github.com/alphagov/govspeak/pull/93)
* Embedded links now will automatically be marked with `rel="external"` [#96](https://github.com/alphagov/govspeak/pull/96)

## 5.0.0

* Update Kramdown version to 1.12.0
* Add pry-byebug to development dependencies
* Ability to run Govspeak as a binary from command line [#87](https://github.com/alphagov/govspeak/pull/87)
* Uses hashes the primary interface for options to commands [#89](https://github.com/alphagov/govspeak/pull/89)
* Adds the `[embed:attachments:image:%content_id%]` extension [#90](https://github.com/alphagov/govspeak/pull/90)
* Renders incorrect usages of embedding content as empty strings rather than outputting markdown [91](https://github.com/alphagov/govspeak/pull/91)

## 4.0.0

* Drop support for Ruby 1.9.3
* Update Ruby to 2.3.1
* Adds support for the following items for feature parity with [whitehall](https://github.com/alphagov/whitehall):
  * `{barchart}`
  * `[embed:attachments:%content_id%]`
  * `[embed:attachments:inline:%content_id%]`
  * `[embed:link:%content_id%]`
  * `[Contact:%content_id%]`
* Changes blockquote rendering to match whitehall [#81](https://github.com/alphagov/govspeak/pull/81)

## 3.7.0

* Update Addressable version from 2.3.8 to 2.4.0

## 3.6.2

* Fix bug with link parsing introduced in Kramdown 1.6.0 with the "inline attribute lists" feature which clashed with our monkey patch [#75](https://github.com/alphagov/govspeak/pull/75)

## 3.6.1

* Update minimum Kramdown version from 1.5.0 to 1.10.0 ([changelog](https://github.com/gettalong/kramdown/tree/2cd02dfacda041d3108a039e085f804645a9d538/doc/news))
* Allow table columns to be left, right or centre aligned using the [standard markdown pattern](http://kramdown.gettalong.org/quickref.html#tables) provided by Kramdown

## 3.6.0

* Yanked, see 3.6.1 which includes [fix](https://github.com/alphagov/govspeak/pull/73)

## 3.5.2

* Fix a couple of issues with the [header_extractor](https://github.com/alphagov/govspeak/blob/master/lib/govspeak/header_extractor.rb). The method now picks up headers nested inside `blocks`, and when ID's are [explicitly set](http://kramdown.gettalong.org/syntax.html#specifying-a-header-id). See [https://github.com/alphagov/govspeak/pull/66](https://github.com/alphagov/govspeak/pull/66) for more.

## 3.5.1

* Continue to support non-strict URIs in links on Ruby 2.2.x. See [https://github.com/alphagov/govspeak/issues/57](https://github.com/alphagov/govspeak/issues/57)

## 3.5.0

* Add `{stat-headline}*10m* big numbers{/stat-headline}` markdown for HTML publications
* `aside` elements are now allowed through the sanitization process.
* Update Ruby from 1.9.3 to 2.1

## 3.4.0

* Increase the version of Kramdown to `1.5.0`. This allows compatibility with Jekyll
  and the GitHub pages gem.

## 3.3.0

* Relax Nokogiri dependency to `1.5.x` rather than `1.5.10`. This allows
  Govspeak to work with Rails 4.2 and greater.

## 3.2.0

* `span` elements are now allowed through the sanitization process.

## 3.1.1

* Fix a bug where address information could get mixed in with preceding paragraph text.

## 3.1.0

* Allow a call to `#valid?` on a `Govspeak::Document` to accept validation options.

## 3.0.0

* Add an `allowed_image_hosts` options to `HtmlValidator` (and `HtmlSanitizer`)
* BREAKING CHANGE: Added the `$EndLegislativeList` tag which allows line breaks in `LegislativeLists`.

## 2.0.2

* Fix a bug with the HtmlValidator to do with kramdown now respecting character
  encodings of input data.

## 2.0.1

* Upgrade to newest kramdown, which fixes a number of bugs, including rendering
  multiple footnote references and handling underscores in attachment titles

## 2.0.0

* Upgrade sanitize dependency to 2.1.0
  * Now allows `address`, `bdi`, `hr` and `summary` elements by default.
  * Allows colons in IDs
  * BREAKING CHANGE: This changes the validation rules of HtmlSanitizer.
* Stop duplicate entries in the sanitization config

## 1.6.2

* Fix a bug with parsing of `$LegislativeList` and `$PriorityList` with `\r\n`
  line endings.

## 1.6.1

* Fix a bug with parsing of `$LegislativeList` and `$PriorityList` so that they
  are not matched when immediately preceeded by other text.

## 1.6.0

* Add `$LegislativeList` to allow editors to insert lists with custom markers.

## 1.5.4

* Stop steps list regex matching newline.

## 1.5.3

* Nested Govspeak blocks are now parsed recursively using Govspeak. Among other
  things, this fixes the display of external links in callout blocks.

## 1.5.2

* Fixed over-eager step list matching.

## 1.5.1

* Fixed newline matching and operating over multiple list blocks.

## 1.5.0

* Added `$PriorityList:x` construct to class the first `x` list items with
  `primary-item`.
* Fixed `rcov` dependency.

## 1.4.0

* Added `#structured_headers` method to provide heirarchically structured
  headers extracted from markdown text heading tags.
