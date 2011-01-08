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
end