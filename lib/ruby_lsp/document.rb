# frozen_string_literal: true

require "strscan"

module RubyLsp
  class Document
    attr_reader :tree, :parser, :source

    def initialize(source)
      @parser = SyntaxTree::Parser.new(source)
      @tree = @parser.parse
      @cache = {}
      @source = source
    end

    def ==(other)
      @source == other.source
    end

    def cache_fetch(request_name)
      cached = @cache[request_name]
      return cached if cached

      result = yield(self)
      @cache[request_name] = result
      result
    end

    def push_edits(edits)
      edits.each do |edit|
        range = edit[:range]
        scanner = Scanner.new(@source)
        start_position = scanner.find_position(range[:start])
        end_position = scanner.find_position(range[:end])

        @source[start_position...end_position] = edit[:text]
      end

      @parser = SyntaxTree::Parser.new(source)
      @tree = @parser.parse
      @cache.clear
    end

    class Scanner
      def initialize(source)
        @source = source
        @scanner = StringScanner.new(source)
        @current_line = 0
        @line_break = Regexp.new("\n")
      end

      def find_position(position)
        # Move the string scanner counting line breaks until we reach the right line
        until @current_line == position[:line]
          @scanner.scan_until(@line_break)
          @current_line += 1
        end

        # The position is: the length of the match until the last line break + the requested character position + the
        # current line to account for line break characters
        (@scanner.pre_match&.length || 0) + position[:character] + @current_line
      end
    end
  end
end
