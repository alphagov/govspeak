Govspeak is our markdown-derived mark-up language.

# Usage

Install the gem

    gem install govspeak

or add it to your Gemfile

    gem "govspeak"

then create a new document

    require 'rubygems'
    require 'govspeak'

    doc = Govspeak::Document.new "^Test^"
    puts doc.to_html

## Changes appearing across GOV.UK

Some additional steps or considerations are needed to ensure changes to govspeak cascade across GOV.UK in a holistic way.

Once govspeak has been updated and version incremented then: 
- [`govuk_publishing_components` govspeak](https://components.publishing.service.gov.uk/component-guide/govspeak) will also need updating to reflect your most recent change.
- [Publishing apps](https://docs.publishing.service.gov.uk/apps.html) (including but not limited to [content-publisher](https://github.com/alphagov/content-publisher) & [whitehall](https://github.com/alphagov/whitehall)) also use govspeak, these apps will need to be released with the new govspeak version present.

Also, consider if:
- [whitehall](https://github.com/alphagov/whitehall) needs updating (as custom govspeak changes are present)
- [govpspeak-preview](https://github.com/alphagov/govspeak-preview) needs updating

Any pages that use govspeak to generate Content will need to *republished* in order for the new changes to be reflected.  

- Data Labs can help identify which pages need updating by [submitting a request](https://gov-uk.atlassian.net/wiki/spaces/GOVUK/pages/1860075525/GOV.UK+Data+Labs#Submitting-a-data-science-request) and [#govuk-2ndline](https://docs.publishing.service.gov.uk/manual/2nd-line.html) can help with republishing
  
# Extensions

In addition to the [standard Markdown syntax](http://daringfireball.net/projects/markdown/syntax "Markdown syntax"), we have added our own extensions.

## Callouts

### Information callouts

    ^This is an information callout^

creates a callout with an info (i) icon.

```html
<div role="note" aria-label="Information" class="application-notice info-notice">
  <p>This is an information callout</p>
</div>
```


### Warning callouts

    %This is a warning callout%

creates a callout with a warning or alert (!) icon

```html
<div role="note" aria-label="Warning" class="application-notice help-notice">
  <p>This is a warning callout</p>
</div>
```

### Example callout

    $E
    **Example**: Open the pod bay doors
    $E

creates an example box

```html
<div class="example">
  <p><strong>Example:</strong> Open the pod bay doors</p>
</div>
```

## Highlights

### Advisory (DEPRECATED: marked for removal. Use 'Information callouts' instead.)

    @This is a very important message or warning@

highlights the enclosed text in yellow

```html
<h3 role="note" aria-label="Important" class="advisory">
  <span>This is a very important message or warning</span>
</h3>
```

### Answer (DEPRECATED: marked for removal)

    {::highlight-answer}
    The VAT rate is *20%*
    {:/highlight-answer}

creates a large highlight box with optional preamble text and giant text denoted with `**`

```html
<div class="highlight-answer">
  <p>The VAT rate is <em>20%</em></p>
</div>
```

### Statistic headline

Used in HTML publications.

Statistic headlines highlight important numbers in content. Displays a statistic as a large number with a description. The statistic and description must make sense when read aloud. The important number must be wrapped in `**`.

```
{stat-headline}
*13.8bn* years since the big bang
{/stat-headline}
```

Creates the following:

```html
<div class="stat-headline">
  <p><em>13.8bn</em> years since the big bang</p>
</div>
```

## Points of Contact

### Contact

    $C
    **Student Finance England**
    **Telephone:** 0845 300 50 90
    **Minicom:** 0845 604 44 34
    $C

creates a contact box

```html
<div class="contact">
  <p>
    <strong>Student Finance England</strong><br>
    <strong>Telephone:</strong> 0845 300 50 90<br>
    <strong>Minicom:</strong> 0845 604 44 34
  </p>
</div>
```

### Address

    $A
    Hercules House
    Hercules Road
    London SE1 7DU
    $A

creates an address box

```html
<div class="address">
  <div class="adr org fn">
    <p>
      Hercules House<br>
      Hercules Road<br>
      London SE1 7DU<br>
    </p>
  </div>
</div>
```

## Downloads

    $D
    [An example form download link](http://example.com/ "Example form")

    Something about this form download
    $D

creates a file download box

```html
<div class="form-download">
  <p><a href="http://example.com/" title="Example form" rel="external">An example form download link.</a></p>
</div>
```

## Place

    $P
    This is a place
    $P

creates a place box

```html
<div class="place">
  <p>This is a place</p>
</div>
```

## Information

    $I
    This is information
    $I

creates an information box

```html
<div class="information">
  <p>This is information</p>
</div>
```

## Additional Information

    $AI
    This is additional information
    $AI

creates an additional information box

```html
<div class="additional-information">
  <p>This is additional information</p>
</div>
```

## Call to Action

    $CTA
    This is a call to action
    $CTA

creates an additional information box

```html
<div class="call-to-action">
  <p>This is a call to action</p>
</div>
```

## Summary

    $!
    This is a summary
    $!

creates a summary box

```html
<div class="summary">
  <p>This is a summary</p>
</div>
```

## External Link

    x[External Report](https://example.com/report)x

creates a link specified as external

```html
<a href="https://example.com/report" rel="external">External Report</a>
```

## Steps

Steps can be created similar to an ordered list:

    s1. numbers
    s2. to the start
    s3. of your list

Note that steps need an extra line break after the final step (ie. two full blank lines) or other markdown directly afterwards won't work. If you have a subhead after - add a line break after this.

## Legislative Lists

For lists where you want to specify the numbering and have multiple indent levels.

    $LegislativeList
    * 1. Item 1
    * 2. Item 2
      * a) Item 2a
      * b) Item 2b
        * i. Item 2 b i
        * ii. Item 2 b ii
    * 3. Item 3
    $EndLegislativeList
    (to indent, add 2 spaces)

## Devolved content

    :england:content goes here:england:
    :scotland:content goes here:scotland:
    :london:content goes here:london:
    :wales:content goes here:wales:
    :northern-ireland:content goes here:northern-ireland:
    :england-wales:content goes here:england-wales:

will create a box for the specified locality

```html
<div class="devolved-content england">
  <p class="devolved-header">This section applies to England</p>
  <div class="devolved-body">
    <p>content goes here</p>
  </div>
</div>
```

## Tables

Tables follow the [Kramdown syntax for tables](https://kramdown.gettalong.org/syntax.html#tables) with one addition - table headers can be specified by adding a `#` at the start of the cell. A table header inside the table head will be given a `scope` of `col`; a table header outside will be given a `scope` of `row`.

```markdown
|               |# Column header one |# Column header two |
|---------------|--------------------|--------------------|
|# Row header 1 | Content #1         | Content #2         |
|# Row header 1 | Content #3         | Content #4         |
```

```html
<table>
  <thead>
    <tr>
      <td></td>
      <th scope="col">Column header one</th>
      <th scope="col">Column header two</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">Row header 1</th>
      <td>Content #1</td>
      <td>Content #2</td>
    </tr>
    <tr>
      <th scope="row">Row header 2</th>
      <td>Content #3</td>
      <td>Content #4</td>
    </tr>
  </tbody>
</table>
```

## Barcharts

For when you want a table to be progressively enhanced by Javascript to be
rendered as a bar chart.

    |col|
    |---|
    |val|
    {barchart}

will be rendered as

```html
<table class="js-barchart-table mc-auto-outdent">
  <thead>
    <tr>
      <th>col</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>val</td>
    </tr>
  </tbody>
</table>
```

## Embedded Content

Embedded content allows authors to reference a supporting item of a document by
referencing an id. The details of this content is passed to the publishing
application to govspeak at the time of rendering.

### Attachments

Attachments can be be rendered as blocks

    [Attachment:file.txt]

with options provided

    {
      attachments: [
        {
          id: "file.txt",
          title: "My attached file",
          url: "http://example.com/file.txt",
          filename: "file.txt",
          content_type: "text/plain",
          file_size: 1024,
        }
      ]
    }

will output an attachment block

```html
<section class="gem-c-attachment">
  <div class="gem-c-attachment__thumbnail">
    <a class="govuk-link" target="_self" tabindex="-1" aria-hidden="true" href="http://example.com/file.txt">
        <svg class="gem-c-attachment__thumbnail-image" version="1.1" viewbox="0 0 84 120" width="84" height="120" aria-hidden="true">
  <path d="M74.85 5v106H5" fill="none" stroke-miterlimit="10" stroke-width="2"></path>
  <path d="M79.85 10v106H10" fill="none" stroke-miterlimit="10" stroke-width="2"></path>
</svg>

</a>
</div>
  <div class="gem-c-attachment__details">
    <h2 class="gem-c-attachment__title">
      <a class="govuk-link" target="_self" href="http://example.com/file.txt">My attached file</a>
</h2>
      <p class="gem-c-attachment__metadata"><span class="gem-c-attachment__attribute">Plain Text</span>, <span class="gem-c-attachment__attribute">1 KB</span></p>


</div></section>
```

### Attachment Links

Attachments can be be rendered inline as links

    Some information about [AttachmentLink:file.pdf]

with options provided

    {
      attachments: [
        {
          id: "file.pdf",
          title: "My PDF",
          url: "http://example.com/file.pdf",
          filename: "file.pdf",
          content_type: "application/pdf",
          file_size: 32768,
          number_of_pages: 2,
        }
      ]
    }

will output an attachment link within a paragraph of text

```html
<p>Some information about <span class="gem-c-attachment-link">
  <a class="govuk-link" href="http://example.com/file.pdf">My PDF</a>

  (<span class="gem-c-attachment-link__attribute"><abbr title="Portable Document Format" class="gem-c-attachment-link__abbr">PDF</abbr></span>, <span class="gem-c-attachment-link__attribute">32 KB</span>, <span class="gem-c-attachment-link__attribute">2 pages</span>)
</span></p>
```

### Inline Attachments (DEPRECATED: use `AttachmentLink:attachment-id` instead)

Attachments can be linked to inline

    Details referenced in [embed:attachments:inline:34f6dda0-21b1-4e78-8120-3ff4dcea522d]

with options provided

    {
      attachments: [
        {
          content_id: "34f6dda0-21b1-4e78-8120-3ff4dcea522d",
          title: "My Thorough Study",
          url: "http://example.com/my-thorough-study.pdf",
        }
      ]
    }

will output an attachment within a block of text

```html
<p>Details referenced in <span class="attachment-inline"><a href="http://example.com/my-thorough-study.pdf">My Thorough Study</a></span></p>
```

### Image Attachments (DEPRECATED: use `Image:image-id` instead)

Attachments can be used to embed an image within the document

    [embed:attachments:image:45ee0eea-bc53-4f14-81eb-9e75d33c4d5e]

with options provided

    {
      attachments: [
        {
          content_id: "45ee0eea-bc53-4f14-81eb-9e75d33c4d5e",
          title: "A lovely landscape",
          url: "http://example.com/lovely-landscape.jpg",
        }
      ]
    }

will output a image section

```html
<figure class="image embedded">
  <div class="img">
    <img src="http://example.com/lovely-landscape.jpg" alt="A Lovely Landscape">
  </div>
</figure>
```

### Images

Images can be embedded as a figure with optional caption.

    [Image:filename.png]

with options provided

    {
      images: [
        {
          alt_text: "Some alt text",
          caption: "An optional caption",
          credit: "An optional credit",
          url: "http://example.com/lovely-landscape.jpg",
          id: "filename.png",
        }
      ]
    }

will output a image section

```html
<figure class="image embedded">
  <div class="img">
    <img src="http://example.com/lovely-landscape.jpg" alt="Some alt text">
    <figcaption>
      <p>An optional caption</p>
      <p>Image credit: An optional credit</p>
    </figcaption>
  </div>
</figure>
```

### Link

Links to different documents can be embedded so they change when the documents
they reference change.

    A link to [embed:link:c636b433-1e5c-46d4-96b0-b5a168fac26c]

with options provided

    {
      links: [
        {
          url: "http://example.com",
          title: "An excellent website",
        }
      ]
    }

will output

```html
<p>A link to <a href="http://example.com">An excellent website</a></p>
```

### Contact

    [Contact:df62690f-34a0-4840-a7fa-4ef5acc18666]

with options provided

    {
      contacts: [
        {
          id: 123,
          content_id: "df62690f-34a0-4840-a7fa-4ef5acc18666",
          title: "Government Digital Service",
          email: "people@digital.cabinet-office.gov.uk",
          contact_numbers: [
            { label: "helpdesk", number: "+4412345 67890"}
          ]
        }
      ]
    }

will output

```html
<div id="contact_123" class="contact">
  <div class="content">
    <div class="vcard contact-inner">
      <p>Government Digital Service</p>
      <div class="email-url-number">
        <p class="email">
          <span class="type">Email</span>
          <a href="mailto:people@digital.cabinet-office.gov.uk" class="email">people@digital.cabinet-office.gov.uk</a>
        </p>
        <p class="tel">
          <span class="type">helpdesk</span>
          +4412345 67890
        </p>
      </div>
    </div>
  </div>
</div>
```

### Button

An accessible way to add button links into content, that can also allow cross domain tracking with [Google Analytics](https://support.google.com/analytics/answer/7372977?hl=en)

This button component uses the component from the [components gem](https://components.publishing.service.gov.uk/component-guide/button) for use in govspeak.

You must use the [link](https://daringfireball.net/projects/markdown/syntax#link) syntax within the button tags.

#### Examples

To get the most basic button.

```
{button}[Continue](https://gov.uk/random){/button}
```

which outputs

```html
<a role="button" class="gem-c-button govuk-button" href="https://gov.uk/random">
  Continue
</a>
```

To turn a button into a ['Start now' button](https://www.gov.uk/service-manual/design/start-pages#start-page-elements), you can pass `start` to the button tag.

```
{button start}[Start Now](https://gov.uk/random){/button}
```

which outputs

```html
<a role="button" class="gem-c-button govuk-button govuk-button--start" href="https://gov.uk/random">
  Start Now
  <svg class="govuk-button__start-icon" xmlns="http://www.w3.org/2000/svg" width="17.5" height="19" viewBox="0 0 33 40" role="presentation" focusable="false"><path fill="currentColor" d="M0 0h13l20 20-20 20H0l20-20z"></path></svg>
</a>
```

You can pass a Google Analytics [tracking id](https://support.google.com/analytics/answer/7372977?hl=en) which will send page views to another domain, this is used to help services understand the start of their users journeys.

```
{button start cross-domain-tracking:UA-XXXXXX-Y}
  [Start Now](https://example.com/external-service/start-now)
{/button}
```

which outputs

```html
<a
  role="button"
  class="gem-c-button govuk-button govuk-button--start"
  href="https://example.com/external-service/start-now"
  data-module="cross-domain-tracking"
  data-tracking-code="UA-XXXXXX-Y"
  data-tracking-name="govspeakButtonTracker"
>
  Start Now
  <svg class="govuk-button__start-icon" xmlns="http://www.w3.org/2000/svg" width="17.5" height="19" viewBox="0 0 33 40" role="presentation" focusable="false"><path fill="currentColor" d="M0 0h13l20 20-20 20H0l20-20z"></path></svg>
</a>
```