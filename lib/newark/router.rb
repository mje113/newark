module Newark
  class Router

    FOUR_O_FOUR = [ 404, {}, [] ].freeze

    attr_accessor :request, :response

    def initialize(app, env)
      @app      = app
      @env      = env
      @request  = Request.new(env)
      @response = Response.new
    end

    def route!
      exec_before_hooks
      route = matched_route(@app.routes)
      if route
        request.params.merge!(route.params)
        response.body = instance_exec(&route.handler)
        exec_after_hooks
        response.finish
      else
        FOUR_O_FOUR
      end
    end

    def matched_route(routes)
      routes.find { |route| route.match?(request) }
    end

    def headers
      response.headers
    end

    def params
      request.params
    end

    private

    def exec_before_hooks
      exec_hooks @app.before_hooks
    end

    def exec_after_hooks
      exec_hooks @app.after_hooks
    end

    def exec_hooks(hooks)
      hooks.each do |hook|
        instance_exec(&hook)
      end
    end

  end
end
