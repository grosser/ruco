module Ruco
  class Application
    attr_reader :editor, :status, :command, :options

    def initialize(file, options)
      @file, go_to_line = parse_file_and_line(file)
      @options = OptionAccessor.new(options)

      setup_actions
      setup_keys
      load_user_config
      create_components

      @editor.move(:to, go_to_line.to_i-1,0) if go_to_line
    end

    def display_info
      [view, style_map, cursor]
    end

    def view
      [status.view, editor.view, command.view].join("\n")
    end

    def style_map
      status.style_map + editor.style_map + command.style_map
    end

    def cursor
      Position.new(@focused.cursor.line + @status_lines, @focused.cursor.column)
    end

    # user typed a key
    def key(key)
      # deactivate select_mode if its not re-enabled in this action
      @select_mode_was_on = @select_mode
      @select_mode = false

      if bound = @bindings[key]
        return execute_action(bound)
      end

      case key

      # move
      when :down then move_with_select_mode :relative, 1,0
      when :right then move_with_select_mode :relative, 0,1
      when :up then move_with_select_mode :relative, -1,0
      when :left then move_with_select_mode :relative, 0,-1
      when :page_up then move_with_select_mode :page_up
      when :page_down then move_with_select_mode :page_down
      when :"Ctrl+right", :"Alt+f" then move_with_select_mode :jump, :right
      when :"Ctrl+left", :"Alt+b" then move_with_select_mode :jump, :left

      # select
      when :"Shift+down" then @focused.selecting { move(:relative, 1, 0) }
      when :"Shift+right" then @focused.selecting { move(:relative, 0, 1) }
      when :"Shift+up" then @focused.selecting { move(:relative, -1, 0) }
      when :"Shift+left" then @focused.selecting { move(:relative, 0, -1) }
      when :"Ctrl+Shift+left", :"Alt+Shift+left" then @focused.selecting{ move(:jump, :left) }
      when :"Shift+end" then @focused.selecting{ move(:to_eol) }
      when :"Shift+home" then @focused.selecting{ move(:to_bol) }


      # modify
      when :tab then
        if @editor.selection
          @editor.indent
        else
          @focused.insert("\t")
        end
      when :"Shift+tab" then @editor.unindent
      when :enter then @focused.insert("\n")
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
      raise "Cannot bind an action and a block" if action and block
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
          ask("Lose changes? Enter=Yes Esc=Cancel") do
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

      action :select_mode do
        @select_mode = !@select_mode_was_on
      end

      action :select_all do
        @focused.move(:to, 0, 0)
        @focused.selecting do
          move(:to, 9999, 9999)
        end
      end

      action :find do
        ask("Find: ", :cache => true) do |result|
          next if editor.find(result)

          if editor.content.include?(result)
            ask("No matches found -- Enter=First match ESC=Stop") do
              editor.move(:to, 0,0)
              editor.find(result)
            end
          else
            ask("No matches found in entire file", :auto_enter => true){}
          end
        end
      end

      action :find_and_replace do
        ask("Find: ", :cache => true) do |term|
          if editor.find(term)
            ask("Replace with: ", :cache => true) do |replace|
              loop_ask("Replace=Enter Skip=s All=a Cancel=Esc", :auto_enter => true) do |ok|
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
      action(:move_line_up){ @editor.move_line(-1) if @focused == @editor }
      action(:move_line_down){ @editor.move_line(1) if @focused == @editor }

      action(:move_to_eol){ move_with_select_mode :to_eol }
      action(:move_to_bol){ move_with_select_mode :to_bol }

      action(:insert_hash_rocket){ @editor.insert(' => ') }
    end

    def setup_keys
      @bindings = {}
      bind :"Ctrl+s", :save
      bind :"Ctrl+w", :quit
      bind :"Ctrl+q", :quit
      bind :"Ctrl+g", :go_to_line
      bind :"Ctrl+f", :find
      bind :"Ctrl+r", :find_and_replace
      bind :"Ctrl+b", :select_mode
      bind :"Ctrl+a", :select_all
      bind :"Ctrl+d", :delete_line
      bind :"Ctrl+l", :insert_hash_rocket
      bind :"Ctrl+x", :cut
      bind :"Ctrl+c", :copy
      bind :"Ctrl+v", :paste
      bind :"Ctrl+z", :undo
      bind :"Ctrl+y", :redo
      bind :"Alt+Ctrl+down", :move_line_down
      bind :"Alt+Ctrl+up", :move_line_up
      bind :end, :move_to_eol
      bind :"Ctrl+e", :move_to_eol # for OsX
      bind :home, :move_to_bol
    end

    def load_user_config
      Ruco.application = self
      config = File.expand_path(@options[:rc] || "~/.ruco.rb")
      load config if File.exist?(config)
    end

    def create_components
      @status_lines = 1

      editor_options = @options.slice(
        :columns, :convert_tabs, :convert_newlines, :undo_stack_size, :color_theme
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

    def parse_file_and_line(file)
      if file.to_s.include?(':') and not File.exist?(file)
        short_file, go_to_line = file.split(':',2)
        if File.exist?(short_file)
          file = short_file
        else
          go_to_line = nil
        end
      end
      [file, go_to_line]
    end

    def move_with_select_mode(*args)
      @select_mode = true if @select_mode_was_on
      if @select_mode
        @focused.selecting do
          move(*args)
        end
      else
        @focused.send(:move, *args)
      end
    end

    def execute_action(action)
      if action.is_a?(Symbol)
        @actions[action].call
      else
        action.call
      end
    end
  end
end
