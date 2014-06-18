lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'benchmark'
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

  get '/hello1' do
    hello
  end

  get 'hello2', :hello

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

  get '/path/*globbing' do
    params[:globbing]
  end

  private

  def hello
    'hello'
  end
end

include Rack::Test::Methods

def app
  App.new
end

# 50_000.times do
#   get '/hello1'
#   get '/hello2'
# end

Benchmark.ips do |x|

  x.report('match /') do
    get '/'
  end

  x.report('handler: block') do
    get '/hello1'
  end

  x.report('handler: method') do
    get '/hello2'
  end

  x.report('match / with param') do
    get '/', user: 'frank'
  end

  x.report('404') do
    get '/not_found'
  end

  x.report('post') do
    post '/create'
  end

  x.report('path params') do
    get '/variables/fu/bar'
  end

  x.report('path globbing') do
    get '/path/a/b/c/d'
  end

end
