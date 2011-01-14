$LOAD_PATH.unshift 'lib'
require 'ruco'

require 'tempfile'
class Tempfile
  def self.string_as_file(data)
    result = nil
    Tempfile.open('foo') do |f|
      f.print data
      f.close
      result = yield(f.path)
    end
    result
  end
end