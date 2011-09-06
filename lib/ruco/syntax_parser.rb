module Ruco
  module SyntaxParser
    def self.parse_lines(lines, language)
      lines.map do |line|
        syntax_positions_in_line(line)
      end
    end

    private

    def self.syntax_positions_in_line(line)
      # adapted from http://nanosyntax.googlecode.com/svn/trunk/syntax-nanorc/ruby.nanorc
      rex = [
        [:comment, /#[^{].*$/],
        [:comment, /\#$/],
        [:string, /"([^"]|(\\"))*"/],
        [:string, /'([^']|(\\'))*'/],
        [:string, /%[QW]?\([^)]*\)/i],
        [:string, /%[QW]?\[[^\]]*\]/i],
        [:string, /%[QW]?\{[^}]*\}/i],
        [:string, /%[QW]?\<[^>]*\>/i],
        [:string, /%[QW]?\![^!]*\!/i],
        [:string, /%[QW]?\^[^^]*\^/i],
        [:string, /`[^`]*`/], # system call
        [:string, /%x\{[^\}]*\}/], # system call
        [:regex, /\/([^\/]|(\\\/))*\/[iomx]*/],
        [:regex, /%r\{([^\}]|(\\\}))*\}[iomx]*/],
        [:symbol, /:[0-9A-Za-z_]+\b/],
        [:class_instance_variable, /@@[0-9A-Z_a-z]+\b/],
        [:instance_variable, /@[0-9A-Z_a-z]+\b/],
        [:constant, /\b[A-Z]+[0-9A-Z_a-z]*\b/],
        [:constant, /\b(__FILE__|__LINE__)\b/],
        [:keyword, /\b(BEGIN|END|alias|and|begin|break|case|class|def|defined\?|do|else|elsif|end|ensure|false|for|if|in|module|next|nil|not|or|redo|rescue|retry|return|self|super|then|true|undef|unless|until|when|while|yield)\b/],
        #[:string_replacement, /#\{[^}]*\}/], # would not be found at since its inside a string
        # HEREDOC
      ]

      matches = []

      rex.each do |type, regex|
        remainder = line
        position = 0

        # find all syntax elements in the line
        loop do
          head, match, tail = remainder.partition(regex)
          break if match.empty?

          # something found, add it to matches and continue on the remainder
          position += head.size

          from_to = position...(position + match.size)

          # ignore if anything was previously found at this position
          unless matches.detect{|t,positions| positions.overlap?(from_to) }
            matches << [type, from_to]
          end

          break if tail.empty?
          remainder = tail
          position += match.size
        end
      end

      matches
    end

  end
end
