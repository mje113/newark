lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'benchmark/ips'
require 'rack/test'
require 'newark'

class App

  include Newark

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

include Rack::Test::Methods

def app
  App.new
end

Benchmark.ips do |x|

  x.report('match /') {
    get '/'
  }

  x.report('match / with param') {
    get '/', user: 'frank'
  }

  x.report('404') {
    get '/not_found'
  }

  x.report('post') {
    post '/create'
  }

  x.report('path params') {
    get '/variables/fu/bar'
  }

end
