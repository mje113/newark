# Base class that represents your Rack app
module Newark
  module App

    FOUR_O_FOUR = [ 404, {}, [] ].freeze

    HTTP_VERBS = [ :delete, :get, :head, :options,
                   :patch, :post, :put, :trace ].freeze

    def self.included(klass)
      klass.instance_variable_set :@routes, {}
      klass.extend ClassMethods
    end

    module ClassMethods

      HTTP_VERBS.each do |verb|
        define_method verb do |path, *args, &block|
          if block.is_a?(Proc)
            handler = block
            constraints = args[0] || {}
          else
            handler = args[0]
            constraints = args[1] || {}
          end

          define_route(verb.to_s.upcase, path, constraints, handler)
        end
      end

      def define_route(verb, path, constraints, handler)
        @routes[verb] ||= []
        @routes[verb] << Route.new(path, constraints, handler)
      end

      def before(&block)
        @before_hooks ||= []
        @before_hooks << block
      end

      def after(&block)
        @after_hooks ||= []
        @after_hooks << block
      end
    end

    attr_reader :request, :response

    def initialize(*)
      super
      @before_hooks = self.class.instance_variable_get(:@before_hooks)
      @after_hooks  = self.class.instance_variable_get(:@after_hooks)
      @routes       = self.class.instance_variable_get(:@routes)
      # @multiplex_routes is a Hash, used to store all the multiplex routes
      # each verb has an array of multiplex routes that represent all the
      # sequential combination of route patterns.
      @multiplex_routes = {}.tap do |values|
        @routes.each do |verb, rtes|
          values[verb] = (0..rtes.size-1).map do |index|
            regexps = rtes[index..-1].map.with_index {|route, i| /(?<_#{i}>#{route.regex})/ }
            /\A#{Regexp.union(regexps)}\z/
          end
        end
      end
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      @env      = env
      @request  = Request.new(@env)
      @response = Response.new
      route
    end

    def headers
      response.headers
    end

    def params
      request.params
    end

    def route
      route = match_route
      if route
        # updates the params in the request based on the keys in the matched route
        unless route.keys.empty?
          match_data = route.regex.match(request.path_info)
          route.keys.each_with_index do |key, i|
            request.params[key] = match_data[i + 1]
          end
        end
        if exec_before_hooks
          response.body = exec(route.handler)
          exec_after_hooks
        end
        status, headers, body = response.finish
        [status, headers, body.respond_to?(:body) ? body.body : body]
      else
        FOUR_O_FOUR
      end
    end

    private

    # a recursive method finds the route by matching the request path
    # by a multiplex matcher
    def match_route(index = 0)
      routes_matcher = routes_matchers[index]
      if routes_matcher === @request.path_info
        last_match_index = Regexp.last_match.captures.find_index {|x| x} + index
        route = routes[last_match_index]
        if route.constraints_match?(@request)
          return route
        else
          return match_route(last_match_index+1)
        end
      end
      nil
    end

    def routes_matchers
      @multiplex_routes[@request.request_method]
    end

    def routes
      @routes[@request.request_method]
    end

    def exec(action)
      if action.respond_to? :to_sym
        send(action)
      else
        instance_exec(&action)
      end
    end

    def exec_handler(handler)
      exec(handler)
    end

    def exec_before_hooks
      exec_hooks @before_hooks
    end

    def exec_after_hooks
      exec_hooks @after_hooks
    end

    def exec_hooks(hooks)
      return true if hooks.nil?
      hooks.each do |hook|
        return false if exec(hook) == false
      end
    end
  end
end
