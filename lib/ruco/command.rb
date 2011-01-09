module Ruco
  # Used to pass around commands
  class Command
    attr_reader :method, :args

    def initialize(method, *args)
      @method = method
      @args = args
    end

    def send_to(object)
      object.send(@method, *@args)
    end

    def ==(other)
      other.method == method and other.args == args
    end
  end
end