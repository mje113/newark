# Base class that represents your Rack app
module Newark
  module App

    FOUR_O_FOUR = [ 404, {}, [] ].freeze

    HTTP_VERBS = [ :delete, :get, :head, :options,
                   :patch, :post, :put, :trace ].freeze

    def self.included(klass)
      klass.instance_variable_set :@routes,       []
      klass.instance_variable_set :@before_hooks, []
      klass.instance_variable_set :@after_hooks,  []
      klass.extend ClassMethods
    end

    module ClassMethods

      HTTP_VERBS.each do |verb|
        define_method verb do |path, options = {}, &block|
          options.merge!(request_method: verb.to_s.upcase)
          define_route(path, options, &block)
        end
      end

      def define_route(path, options, &block)
        @routes << Route.new(path, options, block)
      end

      def before(&block)
        @before_hooks << block
      end

      def after(&block)
        @after_hooks << block
      end
    end

    attr_reader :request, :response

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
        request.params.merge!(route.params)
        if exec_before_hooks.all? { |hook| hook != false }
          response.body = instance_exec(&route.handler)
          exec_after_hooks
        end
        response.finish
      else
        FOUR_O_FOUR
      end
    end

    private

    def match_route
      Router.new(routes, request).route
    end

    def routes
      self.class.instance_variable_get(:@routes)
    end

    def exec_before_hooks
      exec_hooks self.class.instance_variable_get(:@before_hooks)
    end

    def exec_after_hooks
      exec_hooks self.class.instance_variable_get(:@after_hooks)
    end

    def exec_hooks(hooks)
      hooks.map do |hook|
        instance_exec(&hook)
      end
    end
  end
end
