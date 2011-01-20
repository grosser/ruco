# encoding: UTF-8

task :default => :spec
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--backtrace --color'
end

task :run do
  file = 'spec/temp.txt'
  File.open(file, 'w'){|f|f.write("12345\n1234\n#{'abcdefg'*20}\n123")}
  exec "./bin/ruco #{file}"
end

task :try do
  require 'curses'
  Curses.setpos(0,0)
  Curses.addstr("xxxxxxxx\nyyyyyyy");
  Curses.getch
end

task :key do
  begin
    require 'ffi-ncurses'
    NCurses = FFI::NCurses

    NCurses.noecho # do not show typed chars
    NCurses.nonl # turn off newline translation
  #  NCurses.stdscr.keypad(true) # enable arrow keys
    NCurses.raw # give us all other keys
  #  NCurses.stdscr.nodelay = 1 # do not block -> we can use timeouts
    NCurses.initscr

    count = 0
    loop do
      key = NCurses.getch || 4294967295
      next if key == 4294967295
      exit if key == 3 # Ctrl+c
      count = (count + 1) % 20
      NCurses.move(count,0)
      NCurses.addstr("#{key.inspect}    áßðáßf ");
    end
  ensure
    NCurses.endwin
  end
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'ruco'
    gem.summary = "Commandline editor written in ruby"
    gem.email = "michael@grosser.it"
    gem.homepage = "http://github.com/grosser/#{gem.name}"
    gem.authors = ["Michael Grosser"]
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: gem install jeweler"
end
