Govspeak is our markdown-derived mark-up language.

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

    <div class="address vcard"><div class="adr org fn"><p>
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

## Maps

Static Maps can be embedded by wrapping the URL in double parenthesis.

    ((http://maps.google.co.uk/maps?q=Winkfield+Rd,+Windsor,+Berkshire+SL4+4AY&hl=en&sll=53.800651,-4.064941&sspn=17.759517,42.055664&vpsrc=0&z=14))

## Devolved content

    :england:content goes here:england:
    :scotland:content goes here:scotland:
    :london:content goes here:london:
    :wales:content goes here:wales:
    :northern-ireland:content goes here:northern-ireland:
    :england-wales:content goes here:england-wales:

## Usage

govspeak has a basic *Cloth API:

    require 'govspeak'
    Govspeak::Document.new(text).to_html
