require "rspec/json_matcher/version"
require "json"
require "awesome_print"

module RSpec
  module JsonMatcher
    def be_json(expected = nil)
      Matcher.new(expected)
    end

    class Matcher
      attr_reader :expected, :parsed

      def initialize(expected = nil)
        @expected = expected
      end

      def matches?(json)
        @parsed = JSON.parse(json)
        if has_expectation?
          Comparer.compare(parsed, expected)
        else
          true
        end
      rescue JSON::ParserError
        @parser_error = true
        false
      end

      def description
        "be JSON"
      end

      def failure_message_for_should
        if has_parser_error?
          "expected value to be parsed as JSON, but failed"
        else
          inspection
        end
      end

      def failure_message_for_should_not
        if has_parser_error?
          "expected value not to be parsed as JSON, but succeeded"
        else
          inspection("not ")
        end
      end

      private

      def has_parser_error?
        !!@parser_error
      end

      def has_expectation?
        !!expected
      end

      def inspection(prefix = nil)
        ["expected #{prefix}to match:", expected.ai(indent: -2), "", "actual:", parsed.ai(indent: -2)].join("\n")
      end
    end

    class Comparer
      attr_reader :actual, :expected

      def self.compare(*args)
        new(*args).compare
      end

      def self.extract_keys(array_or_hash)
        if array_or_hash.is_a?(Array)
          array_or_hash.each_index.to_a
        else
          array_or_hash.keys
        end
      end

      def initialize(actual, expected)
        @actual   = actual
        @expected = expected
      end

      def compare
        has_same_value? || has_same_collection?
      end

      private

      def has_same_class?
        actual.class == expected.class
      end

      def has_same_keys?
        (self.class.extract_keys(actual) - self.class.extract_keys(expected)).size == 0
      end

      def has_same_value?
        if expected.respond_to?(:call)
          expected.call(actual)
        else
          expected === actual
        end
      end

      def has_same_collection?
        collection? && has_same_class? && has_same_keys? && has_same_values?
      end

      def has_same_values?
        self.class.extract_keys(actual).all? {|key| self.class.compare(actual[key], expected[key]) }
      end

      def collection?
        actual.is_a?(Array) || actual.is_a?(Hash)
      end
    end
  end
end
