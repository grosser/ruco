class Hash
  # 1.9 does not want index and 1.8 does not have key
  alias_method(:key, :index) unless method_defined?(:key)
end
