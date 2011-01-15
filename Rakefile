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

  Curses.cbreak # provide unbuffered input
  Curses.noecho # turn off input echoing
  Curses.nonl # turn off newline translation
  Curses.stdscr.keypad(true) # turn on keypad mode
  Curses.stdscr.nodelay = 1

  
  count = 0
  loop do
    key = Curses.getch or next
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
