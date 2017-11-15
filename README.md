Govspeak is our markdown-derived mark-up language.

# Usage

Install the gem

    gem install govspeak

or add it to your Gemfile

    gem "govspeak", "~> 3.4.0"

then create a new document

    require 'rubygems'
    require 'govspeak'

    doc = Govspeak::Document.new "^Test^"
    puts doc.to_html

or alternatively, run it from the command line

    $ govspeak "render-me"
    $ govspeak --file render-me.md
    $ echo "render-me" | govspeak

options can be passed in through `--options` as a string of JSON or a file
of JSON can be passed in as `--options-file options.json`.

if installed via bundler prefix commands with bundle exec eg `$ bundle exec govspeak "render-me"`


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
<div role="note" aria-label="Help" class="application-notice help-notice">
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

### Advisory

    @This is a very important message or warning@

highlights the enclosed text in yellow

```html
<h3 role="note" aria-label="Important" class="advisory">
  <span>This is a very important message or warning</span>
</h3>
```

### Answer

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
<aside class="stat-headline">
  <p><em>13.8bn</em> years since the big bang</p>
</aside>
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

## Priority Lists

For lists where you want to specify a number of items to be highlighted as priority.

    $PriorityList:3
    - Item 1
    - Item 2
    - Item 3
    - Item 4
    - Item 5

creates a list with priority items flagged with a class

```html
<ul>
  <li class="primary-item">Item 1</li>
  <li class="primary-item">Item 2</li>
  <li class="primary-item">Item 3</li>
  <li>Item 4</li>
  <li>Item 5</li>
</ul>
```

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

To create an attachment callout

    [embed:attachment:2b4d92f3-f8cd-4284-aaaa-25b3a640d26c]

with options provided

    {
      attachments: [
        {
          id: 123,
          content_id: "2b4d92f3-f8cd-4284-aaaa-25b3a640d26c",
          title: "Attachment Title",
          url: "http://example.com/test.pdf",
          order_url: "http://example.com/order",
          price: 12.3,
          isbn: "isbn-123",
          attachment?: true,
        }
      ]
    }

will output an attachment box

```html
<section class="attachment embedded">
  <div class="attachment-thumb">
    <a href="http://example.com/test.pdf" aria-hidden="true" class="embedded"><img src="/images/pub-cover.png" alt="Pub cover"></a>
  </div>
  <div class="attachment-details">
    <h2 class="title">
      <a href="http://example.com/test.pdf" aria-describedby="attachment-123-accessibility-help">Attachment Title</a>
    </h2>
    <p class="metadata">
      <span class="references">Ref: ISBN <span class="isbn">isbn-123</span></span>
    </p>
    <p>
      <a href="http://example.com/order" class="order_url" title="Order a copy of the publication">Order a copy</a>(<span class="price">£12.30</span>)
    </p>
  </div>
</section>
```

### Inline Attachment

Attachments can be linked to inline as well

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

### Image Attachments

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
    <h3>Government Digital Service</h3>
    <div class="vcard contact-inner">
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

This button component is [extended from static](http://govuk-static.herokuapp.com/component-guide/button) for [use in govspeak](http://govuk-static.herokuapp.com/component-guide/govspeak/button)
Note: Ideally we'd use the original component directly but this currently isnt possible

You must use the [link](https://daringfireball.net/projects/markdown/syntax#link) syntax within the button tags.

#### Examples

To get the most basic button.

```
{button}[Continue](https://gov.uk/random){/button}
```

which outputs

```html
<a role="button" class="button" href="https://gov.uk/random">
  Continue
</a>
```

To turn a button into a ['Start now' button](https://www.gov.uk/service-manual/design/start-pages#start-page-elements), you can pass `start` to the button tag.

```
{button start}[Start Now](https://gov.uk/random){/button}
```

which outputs

```html
<a role="button" class="button button-start" href="https://gov.uk/random">
  Start Now
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
  class="button button-start"
  href="https://example.com/external-service/start-now"
  data-module="cross-domain-tracking"
  data-tracking-code="UA-XXXXXX-Y"
  data-tracking-name="govspeakButtonTracker"
>
  Start Now
</a>
```
