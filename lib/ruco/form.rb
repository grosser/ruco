module Ruco
  class Form
    delegate :move, :move_to, :move_to_eol, :move_to_bol, :delete, :to => :text_field

    def initialize(label, options)
      @options = options
      @label = label.strip + ' '
      reset
    end

    def view
      @label + @text_field.view
    end

    def insert(text)
      @text_field.insert(text.gsub("\n",''))
      if text.include?("\n")
        result = @text_field.value
        result = result.to_i if @options[:type] == :integer
        Command.new(@options[:command], result)
      end
    end

    def cursor
      [0, @label.size + @text_field.cursor[1]]
    end

    def reset
      @text_field = TextField.new(:columns => @options[:columns] - @label.size)
    end

    private

    attr_reader :text_field
  end
end