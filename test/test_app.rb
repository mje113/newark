require 'helper'

class NameApp
  include Newark

  before do
    if params[:key] != '123456789'
      response.status = 403
      false
    end
  end

  def upcase(str)
    str.upcase
  end

  get '/upcaser' do
    upcase(params[:name])
  end

  get '/' do
    'Hello'
  end
end

class TestApp < Minitest::Unit::TestCase

  include Rack::Test::Methods

  def app
    NameApp.new
  end

  def test_instance_method_access
    get '/upcaser', { key: '123456789', name: 'mike' }
    assert last_response.ok?
    assert_equal 'MIKE', last_response.body
  end

  def test_before_hooks_halting_execution
    get '/'
    refute last_response.ok?
    assert_equal 403, last_response.status
    assert_equal '', last_response.body
  end

end
