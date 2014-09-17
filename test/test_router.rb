require 'helper'

class TestingApp

  include Newark

  before do
    headers['X-Newark-Version'] = Newark::VERSION
  end

  before do
    if params[:token] && params[:token] == '123456'
      redirect_to 'http://example.com' && return
    end
  end

  after do
    headers['X-Newark-Done'] = 'true'
  end

  get '/', params: { user: 'frank' } do
    'hello frank'
  end

  get '/' do
    'hello'
  end

  get(/\/regexp/) do
    'regexp'
  end

  get '/create' do
    'whoops'
  end

  post '/create' do
    'created'
  end

  get '/request_and_response' do
    request && response
    headers && params
    'ok'
  end

  get '/variables/:a/:b' do
    "#{params[:a]}:#{params[:b]}"
  end

  get '/path_globbing/*rest_of_path' do
    params[:rest_of_path]
  end

  get '/trailing_slash/' do
    'trailing_slash'
  end

  get '/no_trailing_slash' do
    'no_trailing_slash'
  end

  get '/extension_test/:id.xml' do
    "matched in xml: #{params[:id]}"
  end

  get '/multiple_params_extension_test/:id.:format' do
    "matched in #{params[:format]}: #{params[:id]}"
  end

  get '/wildcard_path_test/*path.xml' do
    "matched in #{params[:path]}"
  end

end

class TestRouter < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def app
    Rack::Lint.new(TestingApp.new)
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

  def test_before_hook_stops_rendering
    skip
    get '/', token: '123456'
    assert last_response.redirected?
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

  def test_path_globbing
    get '/path_globbing/rest/of/path'
    assert last_response.ok?
    assert_equal 'rest/of/path', last_response.body
  end

  def test_deals_with_trailing_slashes
    get '/trailing_slash/'
    assert last_response.ok?
    assert_equal 'trailing_slash', last_response.body

    get '/trailing_slash'
    assert last_response.ok?
    assert_equal 'trailing_slash', last_response.body
  end

  def test_deals_with_no_trailing_slashes
    get '/no_trailing_slash/'
    assert last_response.ok?
    assert_equal 'no_trailing_slash', last_response.body

    get '/no_trailing_slash'
    assert last_response.ok?
    assert_equal 'no_trailing_slash', last_response.body
  end

  def test_xml_extension_matching
    get '/extension_test/123.xml'
    assert last_response.ok?
    assert_equal 'matched in xml: 123', last_response.body
  end

  def test_xml_extension_matching
    get '/multiple_params_extension_test/abc.json'
    assert last_response.ok?
    assert_equal 'matched in json: abc', last_response.body
  end

  def test_wildcard_path_matching
    get '/wildcard_path_test/abc/def/g.xml'
    assert last_response.ok?
    assert_equal 'matched in abc/def/g', last_response.body

    get '/wildcard_path_test/abc/def/g.json'
    assert_equal 404, last_response.status
  end

end
