module Ruco
  class TextField < TextArea
    def initialize(options)
      super('', options.merge(:lines => 1))
    end

    def view
      super.gsub("\n",'')
    end

    def value
      content.gsub("\n",'')
    end

    def move(line, column)
      super(0, column)
    end

    def move_to(line, column)
      super(0, column)
    end
  end
end