Govspeak is our markdown-derived mark-up language.

# Usage

Install the gem

    gem install govspeak

or add it to your Gemfile

    gem "govspeak", "~> 0.8.9"

then create a new document

    require 'rubygems'
    require 'govspeak'

    doc = Govspeak::Document.new "^Test^"
    puts doc.to_html

# Extensions

In addition to the [standard Markdown syntax](http://daringfireball.net/projects/markdown/syntax "Markdown syntax"), we have added our own extensions.

## Callouts

### Information callouts

    ^This is an information callout^

creates a callout with an info (i) icon.

    <div class="application-notice info-notice">
    	<p>This is an information callout</p>
    </div>

### Warning callouts

    %This is a warning callout%

creates a callout with a warning or alert (!) icon

    <div class="application-notice help-notice">
    	<p>This is a warning callout</p>
    </div>

### Example callout

    $E
    **Example**: Open the pod bay doors
    $E

creates an example box

    <div class="example">
    <p><strong>Example:</strong> Open the pod bay doors</p>
    </div>

## Highlights

### Advisory

    @This is a very important message or warning@

highlights the enclosed text in yellow

    <h3 class="advisory">
    	<span>This is a very important message or warning</span>
    </h3>

### Answer

    {::highlight-answer}
    The VAT rate is *20%*
    {:/highlight-answer}

creates a large pink highlight box with optional preamble text and giant text denoted with `**`

    <div class="highlight-answer">
    <p>The standard VAT rate is <em>20%</em></p>
    </div>

## Points of Contact

### Contact

    $C
    **Student Finance England**
    **Telephone:** 0845 300 50 90
    **Minicom:** 0845 604 44 34
    $C

creates an contact box

    <div class="contact">
    <p><strong>Student Finance England</strong><br><strong>Telephone:</strong> 0845 300 50 90<br><strong>Minicom:</strong> 0845 604 44 34</p>
    </div>

### Address

    $A
    Hercules House
    Hercules Road
    London SE1 7DU
    $A

creates an address box

    <div class="address"><div class="adr org fn"><p>
    Hercules House
    <br>Hercules Road
    <br>London SE1 7DU
    <br></p></div></div>

## Downloads

    $D
    [An example form download link](http://example.com/ "Example form")

    Something about this form download
    $D

creates a file download box

    <div class="form-download">
    <p><a href="http://example.com/" title="Example form" rel="external">An example form download link.</a></p>
    </div>

## Steps

Steps can be created similar to an ordered list:

    s1. numbers
    s2. to the start
    s3. of your list

Note that steps need an extra line break after the final step (ie. two full blank lines) or other markdown directly afterwards won't work. If you have a subhead after - add a line break after this.

## Abbreviations

Abbreviations can be defined at the end of the document, and any occurrences elswhere in the document will wrapped in an `<abbr>` tag. They are parsed in the order in which they are defined, so `PCSOs` should be defined before `PCSO`, for example.

    Special rules apply if you’re exporting a vehicle outside the EU.

    *[EU]:European Union

becomes

    <p>Special rules apply if you’re exporting a vehicle outside the <abbr title="European Union">EU</abbr>.</p>

## Devolved content

    :england:content goes here:england:
    :scotland:content goes here:scotland:
    :london:content goes here:london:
    :wales:content goes here:wales:
    :northern-ireland:content goes here:northern-ireland:
    :england-wales:content goes here:england-wales:
