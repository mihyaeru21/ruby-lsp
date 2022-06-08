# typed: strict
# frozen_string_literal: true

module RubyLsp
  module Requests
    # The
    # [diagnostics](https://microsoft.github.io/language-server-protocol/specification#textDocument_publishDiagnostics)
    # request informs the editor of RuboCop offenses for a given file.
    #
    # # Example
    #
    # ```ruby
    # def say_hello
    # puts "Hello" # --> diagnostics: incorrect indentantion
    # end
    # ```
    class Diagnostics < RuboCopRequest
      extend T::Sig

      class << self
        extend T::Sig

        sig { returns(Diagnostics) }
        def singleton
          @singleton = T.let(nil, T.nilable(Diagnostics))
          return @singleton if @singleton

          @singleton = Diagnostics.new
        end
      end

      sig do
        override.params(uri: String, document: Document).returns(
          T.any(
            T.all(T::Array[Support::RuboCopDiagnostic], Object),
            T.all(T::Array[Support::SyntaxErrorDiagnostic], Object),
          )
        )
      end
      def run(uri, document)
        return document.syntax_error_edits.map { |e| Support::SyntaxErrorDiagnostic.new(e) } if document.syntax_errors?

        super

        @diagnostics
      end

      sig { params(_file: String, offenses: T::Array[RuboCop::Cop::Offense]).void }
      def file_finished(_file, offenses)
        @diagnostics = offenses.map { |offense| Support::RuboCopDiagnostic.new(offense, T.must(@uri)) }
      end
    end
  end
end
