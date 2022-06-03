# typed: true
# frozen_string_literal: true

require "test_helper"

class SemanticTokenEncoderTest < Minitest::Test
  def test_tokens_encoded_to_relative_positioning
    tokens = [
      stub_token(1, 2, 1, 0, 0),
      stub_token(1, 4, 2, 9, 0),
      stub_token(2, 2, 3, 0, 6),
      stub_token(5, 6, 10, 4, 4),
    ]

    expected_encoding = [
      0, 2, 1, 0, 0,
      0, 2, 2, 9, 0,
      1, 2, 3, 0, 6,
      3, 6, 10, 4, 4,
    ]

    assert_equal(expected_encoding,
      RubyLsp::Requests::Support::SemanticTokenEncoder.new.encode(tokens).data)
  end

  def test_tokens_sorted_before_encoded
    tokens = [
      stub_token(1, 2, 1, 0, 0),
      stub_token(5, 6, 10, 4, 4),
      stub_token(2, 2, 3, 0, 6),
      stub_token(1, 4, 2, 9, 0),
    ]

    expected_encoding = [
      0, 2, 1, 0, 0,
      0, 2, 2, 9, 0,
      1, 2, 3, 0, 6,
      3, 6, 10, 4, 4,
    ]

    assert_equal(expected_encoding,
      RubyLsp::Requests::Support::SemanticTokenEncoder.new.encode(tokens).data)
  end

  private

  def stub_token(start_line, start_column, length, type, modifier)
    RubyLsp::Requests::SemanticHighlighting::SemanticToken.new(
      location: SyntaxTree::Location.new(
        start_line: start_line,
        start_column: start_column,
        start_char: 0,
        end_char: 0,
        end_column: 0,
        end_line: 0,
      ),
      length: length,
      type: type,
      modifier: modifier
    )
  end
end
