class Hash
  # 1.9 does not want index and 1.8 does not have key
  alias_method(:key, :index) unless method_defined?(:key)

  # http://www.ruby-forum.com/topic/149449
  def slice(*keys, &block)
    if block
      each do |key, val|
        boolean = block.call(key, val)
        keys << key if boolean
      end
    end
    hash = self
    keys.inject({}){|returned, key| returned.update key => hash[key]}
  end
end
