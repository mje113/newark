module Newark
  class Route

    PARAM_MATCHER = /:(?<param>[^\/]*)/.freeze
    PARAM_SUB     = /:[^\/]*/.freeze
    PATH_MATCHER  = /\*(?<path>.*)/.freeze
    PATH_SUB      = /\*.*/.freeze

    attr_reader :handler, :name

    def initialize(path, constraints, handler, name)
      fail ArgumentError, 'You must define a route handler' if handler.nil?

      @constraints = Constraint.load(constraints)
      @handler     = handler
      @path        = path_matcher(path)
      @name        = name
    end

    def match?(request)
      path_data = path_match?(request)
      (path_data && constraints_match?(request)).tap do |matched|
        if matched
          request.params.merge! Hash[ path_data.names.zip( path_data.captures ) ]
        end
      end
    end

    private

    def constraints_match?(request)
      @constraints.all? { |constraint| constraint.match?(request) }
    end

    def path_match?(request)
      @path.match(request.path_info)
    end

    def path_matcher(path)
      return path if path.is_a? Regexp
      /^#{path_params(path.to_s)}$/
    end

    def path_params(path)
      match_path(path)
      match_params(path)
      path != '/' ? path.sub(/\/$/, '') : path
    end

    def match_path(path)
      if match = PATH_MATCHER.match(path)
        path.sub!(PATH_SUB, "(?<#{match[:path]}>.*)")
      end
    end

    def match_params(path)
      while match = PARAM_MATCHER.match(path)
        path.sub!(PARAM_SUB, "(?<#{match[:param]}>[^\/]*)")
      end
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
