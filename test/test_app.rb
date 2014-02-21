require 'helper'

class NameApp
  include Newark

  def upcase(str)
    str.upcase
  end

  get '/upcaser' do
    upcase(params[:name])
  end
end

class TestApp < Minitest::Unit::TestCase

  include Rack::Test::Methods

  def app
    NameApp.new
  end

  def test_instance_method_access
    get '/upcaser', { name: 'mike' }
    assert last_response.ok?
    assert_equal 'MIKE', last_response.body
  end

end
