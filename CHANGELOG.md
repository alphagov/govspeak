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
