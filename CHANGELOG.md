## Unreleased

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

## 2.0.2
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
