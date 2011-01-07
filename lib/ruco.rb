require 'ruco/editor'

# http://snippets.dzone.com/posts/show/5119
class Array
  def map_with_index!
    each_with_index do |e, idx| self[idx] = yield(e, idx); end
  end

  def map_with_index(&block)
    dup.map_with_index!(&block)
  end
end

module Ruco
  VERSION = File.read( File.join(File.dirname(__FILE__),'..','VERSION') ).strip
end