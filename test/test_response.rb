require 'helper'
require 'multi_json'

class ResponseApp
  include Newark

  get '/api' do
    { ok: true }
  end
end

class TestResponse < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def app
    Rack::Lint.new(ResponseApp.new)
  end

  def test_json_api
    get '/api'
    assert_equal "{\"ok\":true}", last_response.body
    assert_equal 'application/json', last_response.headers['Content-Type']
  end

end
