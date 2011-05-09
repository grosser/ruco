class File
  def self.write(to, content)
    File.open(to, 'wb'){|f| f.write(content) }
  end
  
  def self.binary_read(file)
    io = File.open(file, 'rb')
    content = io.read
    io.close
    content
  end
end