module Ruco
  class Application
    def initialize(file, options)
      @file = file
      @options = options

      setup_actions
      setup_keys
      load_user_config
      create_components
    end

    def view
      status.view + "\n" + editor.view + command.view
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
      when :enter then
        @focused.insert("\n")
      when :backspace then @focused.delete(-1)
      when :delete then @focused.delete(1)

      when :escape then # escape from focused
        @focused.reset
        @focused = editor
      else
        @focused.insert(key) if key.is_a?(String)
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

    def ask(question, options={}, &block)
      @focused = command
      command.ask(question, options) do |response|
        @focused = editor
        block.call(response)
      end
    end

    def configure(&block)
      instance_exec(&block)
    end

    private

    attr_reader :editor, :status, :command

    def setup_actions
      @actions = {}

      action :save do
        editor.save
      end

      action :quit do
        if editor.modified?
          ask("Loose changes? Enter=Yes Esc=Cancel") do
            :quit
          end
        else
          :quit
        end
      end

      action :go_to_line do
        ask('Go to Line: '){|result| editor.move(:to_line, result.to_i - 1) }
      end

      action :delete_line do
        editor.delete_line
      end

      action :find do
        ask("Find: ", :cache => true){|result| editor.find(result) }
      end
    end

    def setup_keys
      @bindings = {}
      bind :"Ctrl+s", :save
      bind :"Ctrl+w", :quit
      bind :"Ctrl+q", :quit
      bind :"Ctrl+g", :go_to_line
      bind :"Ctrl+f", :find
      bind :"Ctrl+d", :delete_line
    end

    def load_user_config
      Ruco.application = self
      config = File.expand_path("~/.ruco.rb")
      load config if File.exist?(config)
    end

    def create_components
      @status_lines = 1
      command_lines = 1
      editor_lines = @options[:lines] - @status_lines - command_lines
      
      @editor = Ruco::Editor.new(@file, :lines => editor_lines, :columns => @options[:columns])
      @status = Ruco::StatusBar.new(@editor, :columns => @options[:columns])
      @command = Ruco::CommandBar.new(:columns => @options[:columns])
      command.cursor_line = editor_lines
      @focused = @editor
    end
  end
end