# typed: strict
# frozen_string_literal: true

require "rubocop"
require "cgi"

module RubyLsp
  module Requests
    # :nodoc:
    class RuboCopRequest < RuboCop::Runner
      extend T::Sig
      extend T::Helpers

      abstract!

      COMMON_RUBOCOP_FLAGS = T.let([
        "--stderr", # Print any output to stderr so that our stdout does not get polluted
        "--format",
        "RuboCop::Formatter::BaseFormatter", # Suppress any output by using the base formatter
      ].freeze, T::Array[String])

      sig { returns(T.nilable(String)) }
      attr_reader :text

      sig { void }
      def initialize
        @uri = T.let(nil, T.nilable(String))
        @text = T.let(nil, T.nilable(String))
        @options = T.let({}, T::Hash[Symbol, Object])
        @diagnostics = T.let([], T::Array[Support::RuboCopDiagnostic])

        super(
          ::RuboCop::Options.new.parse(rubocop_flags).first,
          ::RuboCop::ConfigStore.new
        )
      end

      sig { overridable.params(uri: String, document: Document).returns(Object) }
      def run(uri, document)
        @uri = uri
        @text = document.source

        file = CGI.unescape(URI.parse(uri).path)
        # We communicate with Rubocop via stdin
        @options[:stdin] = text

        # Invoke the actual run method with just this file in `paths`
        super([file])
      end

      private

      sig { returns(T::Array[String]) }
      def rubocop_flags
        COMMON_RUBOCOP_FLAGS
      end
    end
  end
end
