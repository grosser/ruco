# encoding: UTF-8
require 'bundler/setup'
require 'bundler/gem_tasks'
require 'bump/tasks'

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
