$LOAD_PATH.unshift 'lib'
$ruco_colors = true

require 'ruco'
require 'timeout'
require 'tempfile'

silence_warnings do
  Ruco::Editor::Colors::DEFAULT_THEME = 'spec/fixtures/test.tmTheme'
  Ruco::OLD_VERSION = Ruco::VERSION
  Ruco::VERSION = '0.0.0' # so tests dont fail if version gets longer
end

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
