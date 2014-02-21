module Newark
  class Router

    def initialize(routes, request)
      @routes, @request = routes, request
    end

    def route
      @routes.find { |route| route.match?(@request) }
    end
  end
end
