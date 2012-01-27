Govspeak is our markdown-derived mark-up language.

Extension examples:

^ This is informational text ^
@ This is important text @
% This is helpful text %
These words appear in the glossary: [government],[department],[tax]

All extensions:

^...^ - creates a callout with an info (i) icon.
outputs:
<div class="application-notice info-notice"> 
	<p>This is an information callout</p> 
</div>

%...% - creates a callout with a warning or alert (!) icon.
outputs:
<div class="application-notice help-notice"> 
	<p>This is a warning callout</p> 
</div>

@...@ - highlights the enclosed text in yellow
outputs:
<h3 class="advisory">
	<span>This is a very important message or warning</span>
</h3> 



Devolved content:
:england:content goes here:england:
:scotland:content goes here:scotland:
:london:content goes here:london:
:wales:content goes here:wales:
:northern-ireland:content goes here:northern-ireland:
:england-wales:content goes here:england-wales:

== Usage

govspeak has a basic *Cloth API:

    require 'govspeak'
    Govspeak::Document.new(text).to_html
