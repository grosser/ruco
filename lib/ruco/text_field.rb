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
  end
end