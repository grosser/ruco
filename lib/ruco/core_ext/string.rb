class String
  def naive_split(pattern)
    string = self.dup
    found = []

    while position = string.index(pattern)
      found << string.slice!(0, position)
      string.slice!(0,[pattern.size,1].max)
    end

    found << string
    found
  end

  def nth_index(text, n)
    offset = -1
    (n+1).times do
      offset += 1
      offset = index(text, offset) or return
    end
    offset
  end
end