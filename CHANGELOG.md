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
