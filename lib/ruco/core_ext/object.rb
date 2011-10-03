class Object
  # copy from active_support
  def delegate(*methods)
    options = methods.pop
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, "Delegation needs a target. Supply an options hash with a :to key as the last argument (e.g. delegate :hello, :to => :greeter)."
    end

    methods.each do |method|
      module_eval(<<-EOS, "(__DELEGATION__)", 1)
def #{method}(*args, &block)
#{to}.__send__(#{method.inspect}, *args, &block)
end
EOS
    end
  end unless defined? delegate
end

class Object
  unless defined? instance_exec # 1.9
    module InstanceExecMethods #:nodoc:
    end
    include InstanceExecMethods

    # Evaluate the block with the given arguments within the context of
    # this object, so self is set to the method receiver.
    #
    # From Mauricio's http://eigenclass.org/hiki/bounded+space+instance_exec
    def instance_exec(*args, &block)
      begin
        old_critical, Thread.critical = Thread.critical, true
        n = 0
        n += 1 while respond_to?(method_name = "__instance_exec#{n}")
        InstanceExecMethods.module_eval { define_method(method_name, &block) }
      ensure
        Thread.critical = old_critical
      end

      begin
        send(method_name, *args)
      ensure
        InstanceExecMethods.module_eval { remove_method(method_name) } rescue nil
      end
    end
  end
end

class Object
  def deep_copy
    Marshal.load(Marshal.dump(self))
  end unless defined? deep_copy
end

class Object
  # copy from active_support
  def silence_warnings
    with_warnings(nil) { yield }
  end unless defined? silence_warnings

  # copy from active_support
  def with_warnings(flag)
    old_verbose, $VERBOSE = $VERBOSE, flag
    yield
  ensure
    $VERBOSE = old_verbose
  end unless defined? with_warnings
end

# http://grosser.it/2010/07/23/open-uri-without-ssl-https-verification/
module OpenURI
  def self.without_ssl_verification
    old = ::OpenSSL::SSL::VERIFY_PEER
    silence_warnings{ ::OpenSSL::SSL.const_set :VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE }
    yield
  ensure
    silence_warnings{ ::OpenSSL::SSL.const_set :VERIFY_PEER, old }
  end
end

class Object
  def memoize(*names)
    names.each do |name|
      unmemoized = "__unmemoized_#{name}"
      class_eval %{
        alias   :#{unmemoized} :#{name}
        private :#{unmemoized}
        def #{name}(*args)
          cache = (@#{unmemoized} ||= {})
          if cache.has_key?(args)
            cache[args]
          else
            cache[args] = send(:#{unmemoized}, *args).freeze
          end
        end
      }
    end
  end
end
