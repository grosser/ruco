class File
  def self.write(to, content)
    File.open(to, 'w'){|f| f.write(content) }
  end
end