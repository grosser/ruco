class String
  def naive_split(pattern)
    Dispel::Tools.naive_split(self, pattern)
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

  # https://gist.github.com/20844
  # remove middle from strings exceeding max length.
  def ellipsize(options={})
    max = options[:max] || 40
    delimiter = options[:delimiter] || "..."
    return self if self.size <= max
    remainder = max - delimiter.size
    offset = remainder / 2
    (self[0,offset + (remainder.odd? ? 1 : 0)].to_s + delimiter + self[-offset,offset].to_s)[0,max].to_s
  end unless defined? ellipsize
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
