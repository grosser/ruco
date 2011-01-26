module Ruco
  class Editor
    attr_reader :file
    attr_reader :text_area
    private :text_area
    delegate :view, :selection, :text_in_selection, :color_mask, :selecting, :move, :cursor, :resize, :to => :text_area

    def initialize(file, options)
      @file = file
      content = (File.exist?(@file) ? File.read(@file) : '')
      @text_area = TextArea.new(content, options)
      @modified = false
    end

    def find(text)
      cursor_index = text_area.cursor_index
      return unless start = text_area.content.index(text, cursor_index+1)
      finish = start + text.size
      move(:to_index, finish)
      selecting{ move(:to_index, start) }
    end

    def reset;end

    def insert(text)
      text_area.insert(text)
      @modified = true
    end

    def delete(*args)
      text_area.delete(*args)
      @modified = true
    end

    def delete_line(*args)
      text_area.delete_line(*args)
      @modified = true
    end

    def modified?
      @modified
    end

    def save
      File.open(@file,'w'){|f| f.write(text_area.content) }
      @modified = false
    end
  end
end