module Ruco
  class Application
    attr_reader :editor, :status, :command, :options

    def initialize(file, options)
      @file = file
      if not File.exist?(@file)
        short_file, go_to_line = @file.split(':',2)
        if File.exist?(short_file)
          @file = short_file
        else
          go_to_line = nil
        end
      end

      @options = OptionAccessor.new(options)

      setup_actions
      setup_keys
      load_user_config
      create_components

      @editor.move(:to, go_to_line.to_i-1,0) if go_to_line
    end

    def view
      status.view + "\n" + editor.view + command.view
    end

    def style_map
      reverse = StyleMap.new(1)
      reverse.add(:reverse, 0, 0...@options[:columns])
      reverse + editor.style_map + reverse
    end

    def cursor
      Position.new(@focused.cursor.line + @status_lines, @focused.cursor.column)
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
      when :down then @focused.move(:relative, 1,0)
      when :right then @focused.move(:relative, 0,1)
      when :up then @focused.move(:relative, -1,0)
      when :left then @focused.move(:relative, 0,-1)
      when :end then @focused.move :to_eol
      when :home then @focused.move :to_bol
      when :page_up then @focused.move :page_up
      when :page_down then @focused.move :page_down

      # select
      when :"Shift+down" then
        @focused.selecting do
          move(:relative, 1, 0)
        end
      when :"Shift+right"
        @focused.selecting do
          move(:relative, 0, 1)
        end
      when :"Shift+up"
        @focused.selecting do
          move(:relative, -1, 0)
        end
      when :"Shift+left" then
        @focused.selecting do
          move(:relative, 0, -1)
        end

      # modify
      when :tab then
        if @editor.selection
          @editor.indent
        else
          @focused.insert("\t")
        end
      when :"Shift+tab" then @editor.unindent
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

    def loop_ask(question, options={}, &block)
      ask(question, options) do |result|
        finished = (block.call(result) == :finished)
        loop_ask(question, options, &block) unless finished
      end
    end

    def configure(&block)
      instance_exec(&block)
    end

    def resize(lines, columns)
      @options[:lines] = lines
      @options[:columns] = columns
      create_components
      @editor.resize(editor_lines, columns)
    end

    private

    def setup_actions
      @actions = {}

      action :paste do
        @focused.insert(Clipboard.paste)
      end

      action :copy do
        Clipboard.copy(@focused.text_in_selection)
      end

      action :cut do
        Clipboard.copy(@focused.text_in_selection)
        @focused.delete(0)
      end

      action :save do
        result = editor.save
        if result != true
          ask("#{result.slice(0,100)} -- Enter=Retry Esc=Cancel "){ @actions[:save].call }
        end
      end

      action :quit do
        if editor.modified?
          ask("Loose changes? Enter=Yes Esc=Cancel") do
            editor.store_session
            :quit
          end
        else
          editor.store_session
          :quit
        end
      end

      action :go_to_line do
        ask('Go to Line: ') do |result|
          editor.move(:to_line, result.to_i - 1)
        end
      end

      action :delete_line do
        editor.delete_line
      end

      action :select_all do
        @focused.move(:to, 0, 0)
        @focused.selecting do
          move(:to, 9999, 9999)
        end
      end
      
      action :find do
        ask("Find: ", :cache => true){|result| editor.find(result) }
      end

      action :find_and_replace do
        ask("Find: ", :cache => true) do |term|
          if editor.find(term)
            ask("Replace with: ", :cache => true) do |replace|
              loop_ask("Replace=Enter Skip=s All=a Cancel=Esc") do |ok|
                case ok
                when '' # enter
                  editor.insert(replace)
                when 'a'
                  stop = true
                  editor.insert(replace)
                  editor.insert(replace) while editor.find(term)
                when 's' # do nothing
                else
                  stop = true
                end

                :finished if stop or not editor.find(term)
              end
            end
          end
        end
      end

      action(:undo){ @editor.undo if @focused == @editor }
      action(:redo){ @editor.redo if @focused == @editor }
    end

    def setup_keys
      @bindings = {}
      bind :"Ctrl+s", :save
      bind :"Ctrl+w", :quit
      bind :"Ctrl+q", :quit
      bind :"Ctrl+g", :go_to_line
      bind :"Ctrl+f", :find
      bind :"Ctrl+r", :find_and_replace
      bind :"Ctrl+a", :select_all
      bind :"Ctrl+d", :delete_line
      bind :"Ctrl+x", :cut
      bind :"Ctrl+c", :copy
      bind :"Ctrl+v", :paste
      bind :"Ctrl+z", :undo
      bind :"Ctrl+y", :redo
    end

    def load_user_config
      Ruco.application = self
      config = File.expand_path(@options[:rc] || "~/.ruco.rb")
      load config if File.exist?(config)
    end

    def create_components
      @status_lines = 1

      editor_options = @options.slice(
        :columns, :convert_tabs, :convert_newlines
      ).merge(
        :window => @options.nested(:window),
        :history => @options.nested(:history),
        :lines => editor_lines
      ).merge(@options.nested(:editor))

      @editor ||= Ruco::Editor.new(@file, editor_options)
      @status = Ruco::StatusBar.new(@editor, @options.nested(:status_bar).merge(:columns => options[:columns]))
      @command = Ruco::CommandBar.new(@options.nested(:command_bar).merge(:columns => options[:columns]))
      command.cursor_line = editor_lines
      @focused = @editor
    end

    def editor_lines
      command_lines = 1
      @options[:lines] - @status_lines - command_lines
    end
  end
end