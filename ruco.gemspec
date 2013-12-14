$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
name = "ruco"
require "#{name}/version"

Gem::Specification.new name, Ruco::VERSION do |s|
  s.summary = "Commandline editor written in ruby"
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "https://github.com/grosser/#{name}"
  s.files = `git ls-files lib bin MIT-LICENSE.txt spec/fixtures/railscasts.tmTheme`.split("\n")
  s.executables = ["ruco"]
  s.license = "MIT"
  s.add_runtime_dependency "clipboard", ">= 0.9.8"
  s.add_runtime_dependency "textpow", ">= 1.3.0"
  s.add_runtime_dependency "language_sniffer"
  s.add_runtime_dependency "dispel"
  s.post_install_message = <<-TEXT

    Mac: shift/ctrl + arrow-keys only work in iterm (not Terminal.app)
    Ubuntu: sudo apt-get install xclip # to use the clipboard

  TEXT
end
