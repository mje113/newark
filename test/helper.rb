require 'coveralls'
Coveralls.wear!

require 'pry'
require 'newark'
require 'rack/test'
require 'minitest/autorun'

class App

  include Newark

  before do
    headers['X-Newark-Version'] = Newark::VERSION
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

end

class Minitest::Unit::TestCase

end
