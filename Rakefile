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
  require 'curses'

  Curses.noecho # do not show typed chars
  Curses.nonl # turn off newline translation
  Curses.stdscr.keypad(true) # enable arrow keys
  Curses.raw # give us all other keys
  Curses.stdscr.nodelay = 1 # do not block -> we can use timeouts
  Curses.init_screen

  count = 0
  loop do
    key = Curses.getch || 4294967295
    next if key == 4294967295 
    break if key == ?\C-c
    count = (count + 1) % 20
    Curses.setpos(count,0)
    Curses.addstr("#{key.inspect}     ");
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
