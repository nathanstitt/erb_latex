# ERB LaTeX

Applies ERB template processing to a LaTeX file and compiles it to a PDF.

Supports layouts, partials, and string escaping.

Also supplies a Guard task to watch for modifications and auto-building files.

## Use Case

[Argosity](http://argosity.com/) uses this for several different projects

 * [Nathan](http://nathan.stitt.org/) originally used a bare-bones of this to generate his resume.
 * [Stockor](http://stockor.org/), our open-source ERP platform.  It's used for building all the form that output as PDF.
 * Generating proposals for client projects.

## Api Docs

Are hosted at [nathan.stitt.org/code/erb-latex/](http://nathan.stitt.org/code/erb-latex/)

## Installation

Add this line to your application's Gemfile:

    gem 'erb_latex'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install erb_latex

## Usage

Given a LaTeX layout template: ``layout.tex``

```latex
\documentclass[12pt]{article}
\usepackage{background}
\usepackage{lettrine}
\makeatletter
\AddEverypageHook{
  \SetBgContents{
    \includegraphics[width=\paperwidth]{argosity-background-wave.png}
  }
  \SetBgPosition{current page.south}
  \SetBgAnchor{above}
  \SetBgAngle{0}
  \SetBgScale{1}
  \SetBgVshift{-2mm}
  \SetBgOpacity{0.3}
  \bg@material}
\makeatother
\begin{document}
<%= yield %>
\end{document}
```

and a simple LaTeX body: ``body.tex``

```latex
\lettrine[lines=2]{T}{hank} you for your your consideration.
Please let us know if we can help you any further at all and don't forget to fill out the speakers notes.

<%=q message %>

Thank you,
<%=q author %>
```
The following will convert it to a pdf

```ruby
require "erb_latex"

tmpl = ErbLatex::Template.new( 'body.tex', {
    :layout=>'layout.tex',
    :data=>{
        :author=>"Nathan",
        :messge = "Please call our department at 555-5555"
    }
})
tmpl.to_file('thank-you.pdf')
```
## Guard plugin

ERB LaTeX also includes a plugin for [Guard](https://github.com/guard/guard) to automatically
generate a PDF from a LaTeX file whenever the LaTeX file is modified.

This is useful for shortening the build/review/modify cycle when developing a complex layout.

A Guardfile such as this would compile all *.tex files in a directory

```ruby
require 'erb_latex/guard'

guard :erb_latex do
    watch(%r{.tex$})
end
```

While the one below would compile the hypothetical body.tex file above

```ruby
require 'erb_latex/guard'

guard :erb_latex, :layout=>'proposal.tex', :data=>{:author=>'Nathan Stitt', :message=>'Buy low, Sell High!'} do
    watch 'body.tex'
end
```

## Contributing

1. Fork it ( http://github.com/nathanstitt/erb_latex/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
