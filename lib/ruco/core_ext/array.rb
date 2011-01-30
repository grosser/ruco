# http://snippets.dzone.com/posts/show/5119
class Array
  def map_with_index!
    each_with_index do |e, idx| self[idx] = yield(e, idx); end
  end

  def map_with_index(&block)
    dup.map_with_index!(&block)
  end
end

# TODO move this to cursor <-> use cursor for calculations
class Array
  def between?(a,b)
    self.>= a and self.<= b
  end

  def <(other)
    (self.<=>other) == -1
  end

  def <=(other)
    self.<(other) or self.==other
  end

  def >(other)
    (self.<=>other) == 1
  end

  def >=(other)
    self.>(other) or self.==other
  end
end

# http://madeofcode.com/posts/74-ruby-core-extension-array-sum
class Array
  def sum(method = nil, &block)
    if block_given?
      raise ArgumentError, "You cannot pass a block and a method!" if method
      inject(0) { |sum, i| sum + yield(i) }
    elsif method
      inject(0) { |sum, i| sum + i.send(method) }
    else
      inject(0) { |sum, i| sum + i }
    end
  end
end