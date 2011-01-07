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

  Curses.noecho
  Curses.raw
  
  count = 0
  loop do
    count = (count + 1) % 20
    key = Curses.stdscr.getch
    break if key == ?\C-c
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
