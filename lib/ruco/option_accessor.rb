module Ruco
  # Can be used like a hash, but also allows .key access
  class OptionAccessor
    attr_reader :wrapped
    delegate :[], :[]=, :slice, :to => :wrapped

    def initialize(wrapped={})
      @wrapped = wrapped
    end

    def nested(key)
      Hash[wrapped.map do |k,v|
        if k.to_s =~ /^#{key}_(.*)$/
          [$1.to_sym,v]
        end
      end.compact]
    end

    def method_missing(method, *args)
      base = method.to_s.sub('=','').to_sym
      raise if args.size != 1
      @wrapped[base] = args.first
    end
  end
end