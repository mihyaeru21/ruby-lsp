# typed: strict
# frozen_string_literal: true

module RubyLsp
  module Requests
    # The [formatting](https://microsoft.github.io/language-server-protocol/specification#textDocument_formatting)
    # request uses RuboCop to fix auto-correctable offenses in the document. This requires enabling format on save and
    # registering the ruby-lsp as the Ruby formatter.
    #
    # # Example
    #
    # ```ruby
    # def say_hello
    # puts "Hello" # --> formatting: fixes the indentation on save
    # end
    # ```
    class Formatting < RuboCopRequest
      extend T::Sig

      RUBOCOP_FLAGS = T.let((COMMON_RUBOCOP_FLAGS + ["--autocorrect"]).freeze, T::Array[String])

      class << self
        extend T::Sig

        sig { returns(Formatting) }
        def singleton
          @singleton = T.let(nil, T.nilable(Formatting))
          return @singleton if @singleton

          @singleton = Formatting.new
        end
      end

      sig do
        override.params(
          uri: String,
          document: Document
        ).returns(T.nilable(T.all(T::Array[LanguageServer::Protocol::Interface::TextEdit], Object)))
      end
      def run(uri, document)
        super

        formatted_text = @options[:stdin] # Rubocop applies the corrections on stdin
        return unless formatted_text

        size = T.must(text).size

        [
          LanguageServer::Protocol::Interface::TextEdit.new(
            range: LanguageServer::Protocol::Interface::Range.new(
              start: LanguageServer::Protocol::Interface::Position.new(line: 0, character: 0),
              end: LanguageServer::Protocol::Interface::Position.new(
                line: size,
                character: size
              )
            ),
            new_text: formatted_text
          ),
        ]
      end

      private

      sig { returns(T::Array[String]) }
      def rubocop_flags
        RUBOCOP_FLAGS
      end
    end
  end
end
