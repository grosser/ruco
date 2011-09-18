$LOAD_PATH.unshift 'lib'
$ruco_colors = true

require 'ruco'
require 'timeout'
Ruco::Editor::Colors::RECOLORING_TIMEOUT = 0

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

class Time
  def self.benchmark
    t = Time.now.to_f
    yield
    Time.now.to_f - t
  end
end
