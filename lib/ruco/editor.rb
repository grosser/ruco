module Ruco
  class Editor
    attr_reader :file
    attr_reader :text_area
    attr_reader :history
    private :text_area
    delegate :view, :style_map, :cursor, :position,
      :insert, :indent, :unindent, :delete, :delete_line,
      :redo, :undo, :save_state,
      :selecting, :selection, :text_in_selection, :reset,
      :move, :resize, :move_line,
      :to => :text_area

    def initialize(file, options)
      @file = file
      @options = options

      # check for size (10000 lines * 100 chars should be enough for everybody !?)
      if File.exist?(@file) and File.size(@file) > (1024 * 1024)
        raise "#{@file} is larger than 1MB, did you really want to open that with Ruco?"
      end

      content = (File.exist?(@file) ? File.binary_read(@file) : '')
      @options[:language] ||= LanguageSniffer.detect(@file, :content => content).language
      content.tabs_to_spaces! if @options[:convert_tabs]

      # cleanup newline formats
      @newline = content.match("\r\n|\r|\n")
      @newline = (@newline ? @newline[0] : "\n")
      content.gsub!(/\r\n?/,"\n")

      @saved_content = content
      @text_area = EditorArea.new(content, @options)
      @history = @text_area.history
      restore_session
    end

    def find(text)
      move(:relative, 0,0) # reset selection
      start = text_area.content.index(text, text_area.index_for_position+1)
      return unless start

      # select the found word
      finish = start + text.size
      move(:to_index, finish)
      selecting{ move(:to_index, start) }

      true
    end

    def modified?
      @saved_content != text_area.content
    end

    def save
      lines = text_area.send(:lines)
      lines.each(&:rstrip!) if @options[:remove_trailing_whitespace_on_save]
      lines << '' if @options[:blank_line_before_eof_on_save] and lines.last.to_s !~ /^\s*$/
      content = lines * @newline

      File.open(@file,'wb'){|f| f.write(content) }
      @saved_content = content.gsub(/\r?\n/, "\n")

      true
    rescue Object => e
      e.message
    end

    def store_session
      session_store.set(@file, text_area.state.slice(:position, :screen_position))
    end

    def content
      text_area.content.freeze # no modifications allowed
    end

    private

    def restore_session
      if state = session_store.get(@file)
        text_area.state = state
      end
    end

    def session_store
      FileStore.new(File.expand_path('~/.ruco/sessions'), :keep => 20)
    end
  end
end
