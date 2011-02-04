module Ruco
  class Editor
    attr_reader :file
    attr_reader :text_area
    private :text_area
    delegate :view, :color_mask, :cursor,
      :insert, :indent, :unindent, :delete, :delete_line,
      :redo, :undo,
      :selecting, :selection, :text_in_selection, :reset,
      :move, :resize,
      :to => :text_area

    def initialize(file, options)
      @file = file

      # check for size (10000 lines * 100 chars should be enough for everybody !?)
      if File.exist?(@file) and File.size(@file) > (1024 * 1024)
        raise "#{@file} is larger than 1MB, did you really want to open that with Ruco?"
      end

      content = (File.exist?(@file) ? File.read(@file) : '')
      content.tabs_to_spaces! if options[:convert_tabs]
      raise "Ruco does not support \\r characters" if content.include?("\r")

      @saved_content = content
      @text_area = EditorArea.new(content, options)
    end

    def find(text)
      move(:relative, 0,0) # reset selection
      return unless start = text_area.content.index(text, text_area.index_for_position+1)
      finish = start + text.size
      move(:to_index, finish)
      selecting{ move(:to_index, start) }
      true
    end

    def modified?
      @saved_content != text_area.content
    end

    def save
      content = text_area.content
      File.open(@file,'w'){|f| f.write(content) }
      @saved_content = content
      true
    rescue Object => e
      e.message
    end
  end
end