module Ruco
  class Application
    def initialize(file, options)
      @file = file
      @options = options

      @status_lines = 1
      @command_lines = 1
      @editor_lines = @options[:lines] - @status_lines - @command_lines
      create_components
    end

    def view
      @status.view + "\n" + @editor.view + @command.view
    end

    def cursor
      Cursor.new(@focused.cursor.line + @status_lines, @focused.cursor.column)
    end

    def key(key)
      case key

      # move
      when :up then @focused.move(:relative, -1,0)
      when :down then @focused.move(:relative, 1,0)
      when :right then @focused.move(:relative, 0,1)
      when :left then @focused.move(:relative, 0,-1)
      when :end then @focused.move :to_eol
      when :home then @focused.move :to_bol

      # modify
      when :tab then @focused.insert("\t")
      when 32..126 then @focused.insert(key.chr) # printable
      when :enter then
        result = @focused.insert("\n")
        if result.is_a?(Ruco::Command)
          result.send_to(@editor)
          @focused = @editor
        end
      when :backspace then @focused.delete(-1)
      when :delete then @focused.delete(1)

      # misc
      when :"Ctrl+d" then
        @editor.delete_line
      when :"Ctrl+f" then
        @focused = @command
        @command.find
      when :"Ctrl+g" then
        @focused = @command
        @command.move_to_line
      when :escape then # escape from focused
        @focused.reset
        @focused = @editor
      when :"Ctrl+s" then @editor.save
      when :"Ctrl+w", :"Ctrl+q" then return(:quit) # quit
      end
    end

    def create_components
      @editor = Ruco::Editor.new(@file, :lines => @editor_lines, :columns => @options[:columns])
      @status = Ruco::StatusBar.new(@editor, :columns => @options[:columns])
      @command = Ruco::CommandBar.new(:columns => @options[:columns])
      @command.cursor_line = @editor_lines
      @focused = @editor
    end
  end
end