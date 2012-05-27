# encoding: UTF-8
require 'bundler/gem_tasks'

task :default do
  sh "rspec spec/"
end

desc "Show key-codes you are typing"
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

# extracted from https://github.com/grosser/project_template
rule /^version:bump:.*/ do |t|
  sh "git status | grep 'nothing to commit'" # ensure we are not dirty
  index = ['major', 'minor','patch'].index(t.name.split(':').last)
  file = 'lib/ruco/version.rb'

  version_file = File.read(file)
  old_version, *version_parts = version_file.match(/(\d+)\.(\d+)\.(\d+)/).to_a
  version_parts[index] = version_parts[index].to_i + 1
  version_parts[2] = 0 if index < 2 # remove patch for minor
  version_parts[1] = 0 if index < 1 # remove minor for major
  new_version = version_parts * '.'
  File.open(file,'w'){|f| f.write(version_file.sub(old_version, new_version)) }

  sh "bundle && git add #{file} Gemfile.lock && git commit -m 'bump version to #{new_version}'"
end
