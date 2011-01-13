module Ruco
  class Application
    def initialize(file, options)
      @file = file
      @options = options

      @bindings = {}
      @actions = {}

      @status_lines = 1
      @command_lines = 1
      @editor_lines = @options[:lines] - @status_lines - @command_lines
      create_components

      setup_actions
      setup_keys
    end

    def view
      @status.view + "\n" + @editor.view + @command.view
    end

    def cursor
      Cursor.new(@focused.cursor.line + @status_lines, @focused.cursor.column)
    end

    def key(key)
      if bound = @bindings[key]
        result = if bound.is_a?(Symbol)
          @actions[bound].call
        else
          bound.call
        end
        return result
      end

      case key

      # move
      when :up then @focused.move(:relative, -1,0)
      when :down then @focused.move(:relative, 1,0)
      when :right then @focused.move(:relative, 0,1)
      when :left then @focused.move(:relative, 0,-1)
      when :end then @focused.move :to_eol
      when :home then @focused.move :to_bol
      when :page_up then @focused.move :page_up
      when :page_down then @focused.move :page_down

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

      when :escape then # escape from focused
        @focused.reset
        @focused = @editor
      end
    end

    def bind(key, action=nil, &block)
      raise "Ctrl+m cannot be bound" if key == :"Ctrl+m" # would shadow enter -> bad
      raise if action and block
      @bindings[key] = action || block
    end

    def action(name, &block)
      @actions[name] = block
    end

    private

    def setup_actions
      action :save do
        @editor.save
      end

      action :quit do
        :quit
      end

      action :go_to_line do
        @focused = @command
        @command.move_to_line
      end

      action :delete_line do
        @editor.delete_line
      end

      action :find do
        @focused = @command
        @command.find
      end
    end

    def setup_keys
      bind :"Ctrl+s", :save
      bind :"Ctrl+w", :quit
      bind :"Ctrl+q", :quit
      bind :"Ctrl+g", :go_to_line
      bind :"Ctrl+f", :find
      bind :"Ctrl+d", :delete_line
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