# Newark

A Pico Web Framework

## Installation

Add this line to your application's Gemfile:

    gem 'newark'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install newark

## Usage

```ruby
require 'newark'

class App

  include Newark

  before do
    headers['X-Newark-Version'] = Newark::VERSION
  end

  get '/api/:fu/:bar' do
    "#{params[:fu]}:#{params[:bar]}"
  end
end

run Application.new
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/newark/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
