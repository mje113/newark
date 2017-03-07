require 'helper'

class RouteNameApp

  include Newark

  get '/route' do; end
  get '/route_as_param', name: '/custom_route_name' do; end

end

class TestRouteName < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  class EchoApp

    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
      [200, {}, [ env['newark.route'].name ]]
    end

  end

  def app
    Rack::Lint.new(
      EchoApp.new(
        RouteNameApp.new
      )
    )
  end

  def test_route_name
    get '/route'

    assert_equal '/route', last_response.body
  end

  def test_route_name_as_option
    get '/route_as_param'

    assert_equal '/custom_route_name', last_response.body
  end

  def test_route_name_when_not_found
    get '/i-dont-exist'

    assert_equal '', last_response.body
  end

end
