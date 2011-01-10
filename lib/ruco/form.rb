module Ruco
  class Form
    delegate :move, :delete, :to => :text_field

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
      @text_field.value if text.include?("\n")
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