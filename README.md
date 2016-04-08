# ERB LaTeX

Applies ERB template processing to a LaTeX file and compiles it to a PDF using xelatex.

Supports layouts, partials, string escaping and packages installed in custom directories.

Also supplies a Guard task to watch for modifications and auto-building files.

## Use Case

[Argosity](http://argosity.com/) uses this for several different projects

 * I originally used a bare-bones & hacky version to generate my resume in both HTML & PDF
 * [Stockor](http://stockor.org/), my open-source ERP platform.  It's used for building all the form that output as PDF.
 * Generating proposals for client projects.  Hit me up with a consulting request and you'll probably receive one!

## Links

[API docs](http://www.rubydoc.info/gems/erb_latex),  Source on github at [github.com/nathanstitt/erb_latex](https://github.com/nathanstitt/erb_latex)

## Installation

Add this line to your application's Gemfile:

    gem 'erb_latex'

You'll also need a working tex installation, in particular the xelatex binary. You can get that from [TeX Live](https://www.tug.org/texlive/).

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install erb_latex

## Configuration

```ruby
ErbLatex.configure do | config |
  config.file_extension = '.tex' # defaults to .tex.erb
  config.verbose_logs = true    # will output failure diagnostics to STDERR when enabled
  config.xelatex_path = '/opt/texlive/bin/xelatex' # for cases where xelatex is not located in PATH
end
```

## Usage

Given a LaTeX layout template: ``layout.tex``

```latex
\documentclass[12pt]{article}
\usepackage{background}
\usepackage{lettrine}
\makeatletter
\AddEverypageHook{
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
Please let us know if we can help you!

<%=q @message %>

So long and thanks for all the fish.

Thank you,
<%=q @author %>
```
The following will convert it to a pdf

```ruby
require "erb_latex"

tmpl = ErbLatex::Template.new( 'body.tex', {
    layout: 'layout.tex',
    partial_path: '/my/partials/directory',
    packages_path: '/location/of/custom/latex/packages',
    data: {
        author: "Nathan",
        message: "Please call our department at 555-5555"
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

While the one below would compile the hypothetical body.tex file above.

```ruby
require 'erb_latex/guard'

data = {:author=>'Nathan Stitt', :message=>'Buy low, Sell High!'}
guard :erb_latex, :layout=>'proposal.tex', :data => data do
    watch 'body.tex'
end
```

## Contributing

1. Fork it ( http://github.com/nathanstitt/erb_latex/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
