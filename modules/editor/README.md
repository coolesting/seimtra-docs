## INTRODUCTION

A rich text editor. [markitup](http://markitup.jaysalvat.com/documentation/)
And a markdown parser, [redcarpet](http://www.github.com/vmg/redcarpet)

## USAGE

### add editor

add the code to your template that you want update your simple textarea markup to rich multiple text js editor

	== sys_inc(:editor_markdown)

### parser text

initializing the object in router

	editor_init_parser

and, turn the pure text to html in the template,

	editor_m2h(row[:content])

