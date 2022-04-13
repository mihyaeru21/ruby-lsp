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
      @parsable_source = source
    end

    def ==(other)
      @source == other.source
    end

    def reset(source)
      @parser = SyntaxTree::Parser.new(source)
      @tree = @parser.parse
      @source = source
      @parsable_source = source.dup
      @cache.clear
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

      @cache.clear
      @parser = SyntaxTree::Parser.new(@source)
      @tree = @parser.parse
      @parsable_source = @source.dup
    rescue SyntaxTree::Parser::ParseError
      edits.each do |edit|
        range = edit[:range]
        scanner = Scanner.new(@parsable_source)
        start_position = scanner.find_position(range[:start])
        end_position = scanner.find_position(range[:end])

        @parsable_source[start_position...end_position] = edit[:text].split("").select { |c| c == "\n" }.join
      end

      @parser = SyntaxTree::Parser.new(@parsable_source)
      @tree = @parser.parse
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

        @scanner.pos + position[:character]
      end
    end
  end
end
