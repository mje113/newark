# Base class that represents your Rack app
module Newark
  module App

    def self.included(klass)
      klass.instance_variable_set :@routes,       []
      klass.instance_variable_set :@before_hooks, []
      klass.instance_variable_set :@after_hooks,  []
      klass.extend ClassMethods
    end

    HTTP_VERBS = [ :delete, :get, :head, :options,
                   :patch, :post, :put, :trace ].freeze

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

    def call(env)
      Router.new(self, env).route!
    end

    def routes
      self.class.instance_variable_get :@routes
    end

    def before_hooks
      self.class.instance_variable_get :@before_hooks
    end

    def after_hooks
      self.class.instance_variable_get :@after_hooks
    end
  end
end
