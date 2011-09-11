# encoding: UTF-8

task :default => :spec
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--backtrace --color'
end

task :run do
  file = 'spec/temp.txt'
  File.open(file, 'wb'){|f|f.write("12345\n1234\n#{'abcdefg'*20}\n123")}
  exec "./bin/ruco #{file}"
end

task :try do
  require 'curses'
  Curses.setpos(0,0)
  Curses.addstr("xxxxxxxx\nyyyyyyy");
  Curses.getch
end

task :try_color do
  require 'curses'
  #if Curses::has_colors?
  Curses::start_color
  # initialize every color we want to use
  # id, foreground, background
  Curses::init_pair( Curses::COLOR_BLACK, Curses::COLOR_BLACK, Curses::COLOR_BLACK )
  Curses::init_pair( Curses::COLOR_RED, Curses::COLOR_RED, Curses::COLOR_BLACK )
  Curses::init_pair( Curses::COLOR_GREEN, Curses::COLOR_GREEN, Curses::COLOR_BLACK )
  #end

  Curses.setpos(0,0)
  Curses.attrset(Curses.color_pair(Curses::COLOR_RED)) # fetch color pair with the id xxx
  Curses.addstr("xxxxxxxx\nyyyyyyy");
  Curses.attrset(Curses.color_pair(Curses::COLOR_GREEN))
  Curses.addstr("xxxxxxxx\nyyyyyyy");
  Curses.getch
end

task :key do
  require 'curses'

  Curses.noecho # do not show typed chars
  Curses.nonl # turn off newline translation
  Curses.stdscr.keypad(true) # enable arrow keys
  Curses.raw # give us all other keys
  Curses.stdscr.nodelay = 1 # do not block -> we can use timeouts
  Curses.init_screen
  nothing = (2**32 - 1)


  count = 0
  loop do
    key = Curses.getch || nothing
    next if key >= nothing
    exit if key == 3 # Ctrl+c
    count = (count + 1) % 20
    Curses.setpos(count,0)
    Curses.addstr("#{key.inspect}     ");
  end
end

task :parse do
  require 'ruco/array_processor'
  require 'ultra_pow_list'
  UltraPowList.make_loadable
  require 'textpow'
  require 'uv'
  puts ruby = File.join(Uv.path.first,'uv', 'syntax','ruby.syntax')
  syntax = Textpow::SyntaxNode.load(ruby)
  processor = Ruco::ArrayProcessor.new
  result = syntax.parse( "class Foo\n  def xxx;end\nend",  processor )
  puts result.inspect
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'ruco'
    gem.summary = "Commandline editor written in ruby"
    gem.email = "michael@grosser.it"
    gem.homepage = "http://github.com/grosser/#{gem.name}"
    gem.authors = ["Michael Grosser"]
    gem.post_install_message = <<-TEXT

      Mac: shift/ctrl + arrow-keys only work in iterm (not Terminal.app)
      Ubuntu: sudo apt-get install xclip # to use the clipboard

    TEXT
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: gem install jeweler"
end
