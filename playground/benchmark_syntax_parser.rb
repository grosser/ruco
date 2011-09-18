$LOAD_PATH << 'lib'
require 'oniguruma' if RUBY_VERSION < '1.9.0'
require 'language_sniffer'
gem 'plist'
require 'plist'
gem 'textpow1x'
require 'textpow'
gem 'ultraviolet1x'
require 'uv'

file = ARGV[0]
text = File.read(file)
language = LanguageSniffer.detect(file).language

require 'ruco/syntax_parser'
require 'ruco/array_processor'
t = Time.now.to_f
Ruco::SyntaxParser.parse_lines(text.split("\n"), [language.name.downcase, language.lexer])
Ruco::SyntaxParser.parse_lines(text.split("\n"), [language.name.downcase, language.lexer])
Ruco::SyntaxParser.parse_lines(text.split("\n"), [language.name.downcase, language.lexer])
Ruco::SyntaxParser.parse_lines(text.split("\n"), [language.name.downcase, language.lexer])
Ruco::SyntaxParser.parse_lines(text.split("\n"), [language.name.downcase, language.lexer])
puts (Time.now.to_f - t)
