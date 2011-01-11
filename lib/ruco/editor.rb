module Ruco
  class Editor
    attr_reader :file
    delegate :view, :move, :cursor, :to => :text_area

    def initialize(file, options)
      @file = file
      @options = options
      content = (File.exist?(@file) ? File.read(@file) : '')
      @text_area = TextArea.new(content, @options)
      @modified = false
    end

    def find(text)
      index = text_area.content.index(text, text_area.cursor_index+1) || text_area.cursor_index
      move :to, *text_area.cursor_for_index(index)
    end

    def reset;end

    def insert(text)
      @modified = true
      text_area.insert(text)
    end

    def delete(*args)
      text_area.delete(*args)
      @modified = true
    end

    def modified?
      @modified
    end

    def save
      File.open(@file,'w'){|f| f.write(text_area.content) }
      @modified = false
    end

    private

    attr_reader :text_area
  end
end