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

  def tabs_to_spaces!
    gsub!("\t",' ' * Ruco::TAB_SIZE)
  end

  # stub for 1.8
  unless method_defined?(:force_encoding)
    def force_encoding(encoding)
      self
    end
  end

  unless method_defined?(:ord)
    def ord
      bytes.first
    end
  end
end