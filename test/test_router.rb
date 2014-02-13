require 'helper'
require 'rack/test'

class TestRouter < Minitest::Unit::TestCase

  include Rack::Test::Methods

  def app
    App.new
  end

  def test_gets_root
    get '/'
    assert last_response.ok?
    assert_equal 'hello', last_response.body
  end

  def test_gets_root_with_param_constraint
    get '/', user: 'frank'
    assert last_response.ok?
    assert_equal 'hello frank', last_response.body
  end

  def test_gets_404
    get '/not_found'
    refute last_response.ok?
    assert last_response.not_found?
  end

  def test_gets_by_regexp
    get '/regexp'
    assert last_response.ok?
    assert_equal 'regexp', last_response.body
  end

  def test_post
    post '/create'
    assert last_response.ok?
    assert_equal 'created', last_response.body
  end

  def test_has_access_to_request_and_response
    get '/request_and_response'
    assert last_response.ok?
    assert_equal 'ok', last_response.body
  end

  def test_before_hook
    get '/'
    assert_equal Newark::VERSION, last_response.header['X-Newark-Version']
  end

  def test_after_hook
    get '/'
    assert_equal 'true', last_response.header['X-Newark-Done']
  end

  def test_variable_globbing
    get '/variables/fu/bar'
    assert last_response.ok?
    assert_equal 'fu:bar', last_response.body
  end
end
