# frozen_string_literal: true

require "rubocop"
require "cgi"

module SyntaxTree
  module Translator
    class Parser < Visitor
      def visit_regexp_literal(node)
        children = visit_all(node.parts)

        range = ::Parser::Source::Range.new(buffer, node.location.start_char, node.location.end_char)
        location = ::Parser::Source::Map.new(range)


        children << s(:regopt, node.ending.scan(/[a-z]/).sort.map(&:to_sym), location: location)

        regexp = s(:regexp, children, location: location)

        if stack[-2] in If[predicate: ^(node)] | Unless[predicate: ^(node)]
          s(:match_current_line, [regexp])
        elsif stack[-3] in If[predicate: Unary[statement: ^(node), operator: "!"]] | Unless[predicate: Unary[statement: ^(node), operator: "!"]]
          s(:match_current_line, [regexp])
        elsif stack[-4] in Program[statements: { body: [*, Unary[statement: ^(node), operator: "!"]] }]
          s(:match_current_line, [regexp])
        else
          regexp
        end
      end
    end
  end
end

module RubyLsp
  module Requests
    # :nodoc:
    class RuboCopRequest < RuboCop::Runner
      COMMON_RUBOCOP_FLAGS = [
        "--stderr", # Print any output to stderr so that our stdout does not get polluted
        "--format",
        "RuboCop::Formatter::BaseFormatter", # Suppress any output by using the base formatter
      ].freeze

      attr_reader :file, :text

      def self.run(uri, document)
        new(uri, document).run
      end

      def initialize(uri, document)
        @file = CGI.unescape(URI.parse(uri).path)
        @document = document
        @text = document.source
        @uri = uri

        Parser::Base.define_method(:do_parse) { document.ast_tree }

        super(
          ::RuboCop::Options.new.parse(rubocop_flags).first,
          ::RuboCop::ConfigStore.new
        )
      end

      def run
        # We communicate with Rubocop via stdin
        @options[:stdin] = text

        # Invoke the actual run method with just this file in `paths`
        super([file])
      end

      private

      def rubocop_flags
        COMMON_RUBOCOP_FLAGS
      end
    end
  end
end
