require 'rack'
require 'newark/version'
require 'newark/app'
require 'newark/route'
require 'newark/router'
require 'newark/request'
require 'newark/response'

module Newark

  def self.included(klass)
    klass.send :include, App
  end

end
