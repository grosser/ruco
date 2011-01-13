Commandline editor written in ruby

Alpha, lets see if this works...

Finished:

 - viewing / scrolling / editing / saving / creating
 - Home/End + Page up/down
 - basic Tab support (tab == 2 space)
 - change-indicator (*)
 - writeable indicator (!)
 - backspace / delete
 - find / go to line
 - delete line

Install
=======
    sudo gem install ruco

Usage
=====
    ruco file.rb

TODO
=====
 - ask before quitting on changed file
 - bind/action must use instance_exec
 - read .rucorc.rb
 - write key binding guide
 - smart staying at end of line/column when changing line
 - indentation + paste support
 - warnings / messages
 - syntax highlighting

Author
======
[Michael Grosser](http://grosser.it)  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...
