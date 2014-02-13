module Newark
  class Route

    PARAM_MATCHER = /:(?<param>[^\/]*)/.freeze

    attr_reader :handler, :params

    def initialize(path, constraints, handler)
      @constraints = Constraint.load(constraints)
      @handler     = handler
      @path        = path_matcher(path)
      @params      = nil
    end

    def match?(request)
      path_data = path_match?(request)
      if path_data && constraints_match?(request)
        @params = Hash[ path_data.names.zip( path_data.captures ) ]
      end
    end

    private

    def constraints_match?(request)
      @constraints.all? { |constraint| constraint.match?(request) }
    end

    def path_match?(request)
      @path.match(request.path)
    end

    def path_matcher(path)
      return path if path.is_a? Regexp
      /^#{path_params(path.to_s)}$/
    end

    def path_params(path)
      return path unless path =~ /:/

      while match = PARAM_MATCHER.match(path)
        path.sub!(/:[^\/]*/, "(?<#{match[:param]}>[^\/]*)")
      end
      path
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
