require 'ruco/core_ext/object'
require 'ruco/core_ext/string'
require 'ruco/core_ext/array'
require 'ruco/core_ext/hash'
require 'ruco/core_ext/range'

require 'ruco/keyboard'
require 'ruco/cursor'

require 'ruco/editor'
require 'ruco/status_bar'
require 'ruco/command_bar'
require 'ruco/application'

require 'ruco/form'
require 'ruco/text_area'
require 'ruco/text_field'

module Ruco
  autoload :Clipboard, 'clipboard' # can crash when loaded -> load if needed

  VERSION = File.read( File.join(File.dirname(__FILE__),'..','VERSION') ).strip
  TAB_SIZE = 2

  class << self
    attr_accessor :application
  end

  def self.configure(&block)
    application.instance_exec(&block)
  end
end