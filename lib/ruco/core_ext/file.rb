class File
  def self.write(to, content)
    File.open(to, 'wb'){|f| f.write(content) }
  end
  
  # Open files in binary mode. On linux this is ignored by ruby.
  # On Windows ruby open files in text mode by default, so it replaces \r with \n,
  # so the specs fail. If files are opened in binary mode, which is the only mode 
  # on linux, it does not replace the newlines. This thread has slightly more information:
  # http://groups.google.com/group/rubyinstaller/browse_thread/thread/c7fbe346831e58cc
  def self.binary_read(file)
    io = File.open(file, 'rb')
    content = io.read
    io.close
    content
  end
end