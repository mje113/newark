require 'helper'

class RequestApp
  include Newark

  get '/uri' do
    request.uri.to_s
  end

  get '/headers' do
    request.headers['X-Fu']
  end

  post '/body' do
    request.body
  end

  get '/request_id' do
    request.request_id
  end
end

class TestRequest < Minitest::Unit::TestCase

  include Rack::Test::Methods

  def app
    RequestApp.new
  end

  def test_uri
    get '/uri', { fu: 'bar' }
    assert_equal 'http://example.org/uri?fu=bar', last_response.body
  end

  def test_headers
    get '/headers', {}, { 'HTTP_X_FU' => 'Bar' }
    assert_equal 'Bar', last_response.body
  end

  def test_headers_with_odd_format
    get '/headers', {}, { 'HTTP_X-fu' => 'Bar' }
    assert_equal 'Bar', last_response.body
  end

  def test_body
    post '/body', {}, { 'rack.input' => StringIO.new('fubar') }
    assert_equal 'fubar', last_response.body
  end

  def test_request_id
    get '/request_id'
    refute last_response.body.empty?
  end

  def test_request_id_when_passed
    request_id = '1234567890'
    get '/request_id', {}, { 'HTTP_X_REQUEST_ID' => request_id }
    assert_equal request_id, last_response.body
  end

end
