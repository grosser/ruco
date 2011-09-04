Simple, extendable, test-driven commandline editor written in ruby, for Linux/Mac/Windows.

### Features

 - **Desktop-like / intuitive interface**
 - selecting via Shift + arrow-keys (only Linux or iTerm) or 'select mode' Ctrl+b + arrow-keys
 - move line up/down (Alt+Ctrl+up/down)
 - Tab -> indent / Shift+Tab -> unindent
 - keeps indentation (+ paste-detection e.g. via Cmd+v)
 - change (*) + writable (!) indicators
 - find / go to line / delete line / search & replace
 - configuration via `~/.ruco.rb` in Ruby
 - Full clipboard support -> Ctrl+x/c/v
 - undo / redo -> Ctrl+z/y
 - stays at last position when reopening a file
 - opens file at line e.g. `ruco foo/bar.rb:32`
 - supports all newline formats
 - surrounds selection with quotes/braces (select abc + " --> "abc")
 - shortens long file names in the middle
 - (optional) remove trailing whitespace on save
 - (optional) blank line before eof on save
 - (optional) line numbers

### Architecture
Ruco is basically a lot of String manipulation separated in HTML style elements.
The only component dealing with the commandline interface are Screen and Keyboard. Therefore
everything is very simple to build and test since it returns a string or a e.g. cursor position.

Writing/reading is done in a TextArea or a TextField (a TextArea with 1 line)
which are placed in Form`s.

The Application consists of a StatusBar, Editor, CommandBar and delegates actions to the currently active element.

To build the commandline output Editor/CommandBar return:

 - view -- text that should be displayed on the screen (complete content cropped via Window)
 - style_map -- a big Array with style infos, e.g. 'on line 1 chars 5 to 7 are red'
 - cursor -- where to draw the cursor

Install
=======
    sudo gem install ruco

Usage
=====
    ruco file.rb

Customize
=========

    # ~/.ruco.rb
    Ruco.configure do
      # set options
      options.window_line_scroll_offset = 5 # default 1
      options.history_entries = 10          # default 100
      options.editor_remove_trailing_whitespace_on_save = true  # default false
      options.editor_blank_line_before_eof_on_save = true       # default false
      options.editor_line_numbers = true                        # default false
      ...

      # bind a key
      # - you can use Integers and Symbols
      # - use "ruco --debug-keys foo" to see which keys are possible
      # - have a look at lib/ruco/keyboard.rb
      bind(:"Ctrl+e") do
        ask('foo') do |response|
          if response == 'bar'
            editor.insert('baz')
          else
            editor.move(:to, 0,0)
            editor.delete(99999)
            editor.insert('FAIL!')
          end
        end
      end

      # bind an existing action
      puts @actions.keys

      bind :"Ctrl+x", :quit
      bind :"Ctrl+o", :save
      bind :"Ctrl+k", :delete_line
      bind :"Ctrl+e", :move_to_eol
      bind :"Ctrl+a", :move_to_bol

      # create reusable actions
      action(:first_line){ editor.move(:to_column, 0) }
      bind :"Ctrl+u", :first_line
    end

TIPS
====
 - [Mac] arow-keys + Shift/Alt does not work in default terminal (use iTerm)
 - [Tabs] Ruco does not like tabs. Existing tabs are displayed as single space and pressing tab inserts 2*space
 - [RVM] `alias r="rvm 1.9.2 exec ruco"` and you only have to install ruco once
 - [Ruby1.9] Unicode support -> install libncursesw5-dev before installing ruby
 - [ssh vs clipboard] access your desktops clipboard by installing `xauth` on the server and then using `ssh -X`
 - [Alt key] if Alt does not work try your Meta/Win/Cmd key



TODO
=====
 - do not fall back to 0:0 after undoing the first change
 - check writable status every x seconds (e.g. in background) -> faster while typing
 - search help e.g. 'Nothing found' '#4 of 6 hits' 'no more hits, start from beginning ?'
 - align soft-tabs
 - highlight tabs (e.g. strange character or reverse/underline/color)
 - big warning when editing a not-writable file
 - find next (Alt+n)
 - smart staying at column when changing line
 - syntax highlighting
 - raise when binding to a unsupported key
 - search history via up/down arrow
 - search options regex + case-sensitive
 - 1.8: unicode support <-> already finished but unusable due to Curses (see encoding branch)
 - add double quotes/braces when typing one + skip over quote/brace when its already typed at current position

Authors
=======

### [Contributors](http://github.com/grosser/ruco/contributors)
 - [AJ Palkovic](https://github.com/ajpalkovic)


[Michael Grosser](http://grosser.it)<br/>
grosser.michael@gmail.com<br/>
Hereby placed under public domain, do what you want, just do not hold me accountable...
