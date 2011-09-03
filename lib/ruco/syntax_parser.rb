module Ruco
  module SyntaxParser
    def self.parse_lines(lines, language)
      lines.map do |line|
        syntax_positions_in_line(line)
      end
    end

    private

    def self.syntax_positions_in_line(line)
      keywords = /\b(BEGIN|END|alias|and|begin|break|case|class|def|defined\?|do|else|elsif|end|ensure|false|for|if|in|module|next|nil|not|or|redo|rescue|retry|return|self|super|then|true|undef|unless|until|when|while|yield)\b/
      matches = []
      remainder = line
      position = 0

      # find all syntax elements in the line
      loop do
        head, match, tail = remainder.partition(keywords)
        break if match.empty?

        # something found, add it to matches and continue on the remainder
        position += head.size
        matches << [:keyword, position...(position + match.size)]

        break if tail.empty?
        remainder = tail
        position += match.size
      end
      matches
    end

  end
end
