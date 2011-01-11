require 'ruco/core_ext/object'
require 'ruco/core_ext/string'
require 'ruco/core_ext/array'

require 'ruco/focusable'
require 'ruco/command'

require 'ruco/editor'
require 'ruco/status_bar'
require 'ruco/command_bar'

require 'ruco/form'
require 'ruco/text_area'
require 'ruco/text_field'

module Ruco
  VERSION = File.read( File.join(File.dirname(__FILE__),'..','VERSION') ).strip
  TAB_SIZE = 2
end