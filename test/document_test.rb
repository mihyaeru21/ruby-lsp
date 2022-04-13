# frozen_string_literal: true

require "test_helper"

class DocumentTest < Minitest::Test
  # TODO: test deletion, test multi cursor, test replace
  def test_valid_incremental_edits
    document = RubyLsp::Document.new(+<<~RUBY)
      def foo
      end
    RUBY

    # Write puts 'a' in incremental edits
    document.push_edits([{ range: { start: { line: 0, character: 7 }, end: { line: 0, character: 7 } }, text: "\n  " }])
    document.push_edits([{ range: { start: { line: 1, character: 2 }, end: { line: 1, character: 2 } }, text: "p" }])
    document.push_edits([{ range: { start: { line: 1, character: 3 }, end: { line: 1, character: 3 } }, text: "u" }])
    document.push_edits([{ range: { start: { line: 1, character: 4 }, end: { line: 1, character: 4 } }, text: "t" }])
    document.push_edits([{ range: { start: { line: 1, character: 5 }, end: { line: 1, character: 5 } }, text: "s" }])
    document.push_edits([{ range: { start: { line: 1, character: 6 }, end: { line: 1, character: 6 } }, text: " " }])
    document.push_edits([{ range: { start: { line: 1, character: 7 }, end: { line: 1, character: 7 } }, text: "''" }])
    document.push_edits([{ range: { start: { line: 1, character: 8 }, end: { line: 1, character: 8 } }, text: "a" }])
    document.push_edits([{ range: { start: { line: 1, character: 9 }, end: { line: 1, character: 10 } }, text: "'" }])

    assert_equal(<<~RUBY, document.source)
      def foo
        puts 'a'
      end
    RUBY
  end

  def test_deletion_full_node
    document = RubyLsp::Document.new(+<<~RUBY)
      def foo
        puts 'a' # comment
      end
    RUBY

    # Delete puts 'a' in incremental edits
    document.push_edits([{ range: { start: { line: 1, character: 2 }, end: { line: 1, character: 11 } }, text: "" }])

    assert_equal(<<~RUBY, document.source)
      def foo
        # comment
      end
    RUBY
  end

  def test_deletion_single_character
    document = RubyLsp::Document.new(+<<~RUBY)
      def foo
        puts 'a'
      end
    RUBY

    # Delete puts 'a' in incremental edits
    document.push_edits([{ range: { start: { line: 1, character: 8 }, end: { line: 1, character: 9 } }, text: "" }])

    assert_equal(<<~RUBY, document.source)
      def foo
        puts ''
      end
    RUBY
  end

  def test_add_delete_single_character
    document = RubyLsp::Document.new(+"")

    # Add a
    document.push_edits([{ range: { start: { line: 0, character: 0 }, end: { line: 0, character: 0 } }, text: "a" }])

    assert_equal("a", document.source)

    # Delete a
    document.push_edits([{ range: { start: { line: 0, character: 0 }, end: { line: 0, character: 1 } }, text: "" }])

    assert_empty(document.source)
  end

  def test_replace
    document = RubyLsp::Document.new(+"puts 'a'")

    # Replace for puts 'b'
    document.push_edits([{ range: { start: { line: 0, character: 0 }, end: { line: 0, character: 8 } },
                           text: "puts 'b'", }])

    assert_equal("puts 'b'", document.source)
  end

  def test_make_it_work
    document = RubyLsp::Document.new(+<<~RUBY)
      # frozen_string_literal: true

      class Foo
        def foo
        end
      end
    RUBY

    # Write puts 'a' in incremental edits
    document.push_edits([{:range=>{:start=>{:line=>3, :character=>9}, :end=>{:line=>3, :character=>9}}, :rangeLength=>0, :text=>"\n    "}])
    document.push_edits([{:range=>{:start=>{:line=>4, :character=>4}, :end=>{:line=>4, :character=>4}}, :rangeLength=>0, :text=>"a"}])

    assert_equal(<<~RUBY, document.source)
      # frozen_string_literal: true

      class Foo
        def foo
          a
        end
      end
    RUBY
  end
end
