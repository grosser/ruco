module Ruco
  class Editor
    attr_reader :file
    attr_reader :text_area
    private :text_area
    delegate :view, :color_mask, :cursor,
      :selecting, :selection, :text_in_selection, :reset,
      :move, :resize,
      :to => :text_area

    def initialize(file, options)
      @file = file
      content = (File.exist?(@file) ? File.read(@file) : '')
      if content.include?("\t")
        if options[:convert_tabs]
          content.tabs_to_spaces!
        else
          raise "#{@file} contains tabs.\nRuco atm does not support tabs, but will happily convert them to spaces if started with --convert-tabs or -c"
        end
      end
      @text_area = EditorArea.new(content, options)
      @modified = false
    end

    def find(text)
      move(:relative, 0,0) # reset selection
      return unless start = text_area.content.index(text, text_area.index_for_position+1)
      finish = start + text.size
      move(:to_index, finish)
      selecting{ move(:to_index, start) }
      true
    end

    def insert(text)
      text_area.insert(text)
      @modified = true
    end

    def indent(*args)
      text_area.indent(*args)
      @modified = true
    end

    def unindent(*args)
      text_area.unindent(*args)
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