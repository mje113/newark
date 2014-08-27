module Newark
  class Route

    PLACEHOLDER_REGEXP = {
      /:(\w+)/    => "([^#?/]+)", # any wildcard param that starts with ":"
      /\\\*(\w+)/ => "([^#?]+)"   # any wildcard param that starts with "*"
    }

    attr_reader :handler, :regex, :keys

    def initialize(path, constraints, handler)
      fail ArgumentError, 'You must define a route handler' if handler.nil?

      @constraints = Constraint.load(constraints)
      @handler     = handler
      @regex, @keys = path_matcher(path)
    end

    def constraints_match?(request)
      @constraints.all? { |constraint| constraint.match?(request) }
    end

    private

    def path_matcher(path)
      path.is_a?(Regexp) ? [path, []] : compile(path)
    end

    # compiles a path pattern to derive a regex and all the keys
    def compile(path_pattern)
      keys = []
      segments = []
      path_pattern.split("/").each do |segment|
        segments << Regexp.escape(segment).tap do |reg|
          PLACEHOLDER_REGEXP.each do |placeholder, replacement|
            reg.gsub!(placeholder) do
              keys << $1
              replacement
            end
          end
        end
      end
      return Regexp.new(segments.any? ? segments.join(?/) : ?/), keys
    end

    class Constraint

      attr_reader :field, :matchers

      # Expects a hash of constraints
      def self.load(constraints)
        fail ArgumentError unless constraints.is_a?(Hash)
        constraints.map { |field, matcher| Constraint.new(field, matcher) }
      end

      def initialize(field, match_or_matchers)
        @field    = field
        @matchers = make_matchers_regexp(match_or_matchers)
      end

      def match?(request)
        if request.respond_to?(field)
          constrained = request.send(field)

          if matchers.is_a?(Hash) && constrained.is_a?(Hash)
            hash_match?(request, constrained, matchers)
          else
            constrained =~ matchers
          end
        end
      end

      private

      def hash_match?(request, constrained, matchers)
        matchers.all? { |key, matcher|
          constrained[key] =~ matcher
        }
      end

      def make_matchers_regexp(match_or_matchers)
        if match_or_matchers.is_a? Hash
          {}.tap do |matchers|
            match_or_matchers.each do |k, v|
              matchers[k] = matcher_to_regex(v)
            end
          end
        else
          matcher_to_regex(match_or_matchers)
        end
      end

      def matcher_to_regex(matcher)
        return matcher if matcher.is_a? Regexp
        /^#{matcher.to_s}$/
      end
    end

  end
end
