require 'ruco/version'

require 'ruco/core_ext/object'
require 'ruco/core_ext/string'
require 'ruco/core_ext/array'
require 'ruco/core_ext/hash'
require 'ruco/core_ext/range'
require 'ruco/core_ext/file'

require 'ruco/keyboard'
require 'ruco/position'
require 'ruco/history'
require 'ruco/option_accessor'
require 'ruco/file_store'
require 'ruco/window'
require 'ruco/screen'
require 'ruco/style_map'
require 'ruco/syntax_parser'

require 'ruco/editor'
require 'ruco/editor/line_numbers'
require 'ruco/editor/history'
require 'ruco/status_bar'
require 'ruco/command_bar'
require 'ruco/application'

require 'ruco/form'
require 'ruco/text_area'
require 'ruco/editor_area'
require 'ruco/text_field'

begin
  require 'oniguruma'
  require 'plist'
  require 'textpow'
  require 'uv'
  require 'ruco/array_processor'
  require 'ruco/tm_theme'
rescue LoadError
  warn "Could not load color libs -- #{$!}"
end

module Ruco
  autoload :Clipboard, 'clipboard' # can crash when loaded -> load if needed

  TAB_SIZE = 2

  class << self
    attr_accessor :application
  end

  def self.configure(&block)
    application.instance_exec(&block)
  end
end
