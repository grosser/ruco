module Ruco
  class Editor
    def initialize(file, options)
      @file = file
      @options = options
      @content = File.read(@file)
    end

    def view
      lines = @content.split("\n")
      Array.new(@options[:lines]).map_with_index do |_,i|
        (lines[i] || "").slice(0, @options[:columns])
      end.join("\n") + "\n"
    end
  end
end