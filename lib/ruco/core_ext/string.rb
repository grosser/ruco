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

  def leading_whitespace
    match(/^\s*/)[0]
  end

  def leading_whitespace=(whitespace)
    sub!(/^\s*/, whitespace)
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

  def surrounded_in?(*words)
    first = words.first
    last = words.last
    slice(0,first.size) == first and slice(-last.size,last.size) == last
  end
end

# http://grosser.it/2010/12/31/ruby-string-indexes-indices-find-all-indexes-in-a-string
class String
  def indexes(needle)
    found = []
    current_index = -1
    while current_index = index(needle, current_index+1)
      found << current_index
    end
    found
  end
end
