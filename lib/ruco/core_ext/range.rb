class Range
  # http://stackoverflow.com/questions/699448/ruby-how-do-you-check-whether-a-range-contains-a-subset-of-another-range
  def overlap?(other)
    (first <= other.last) and (other.first <= last)
  end
end