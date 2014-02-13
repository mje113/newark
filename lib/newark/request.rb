require 'active_support/hash_with_indifferent_access'

module Newark
  class Request < Rack::Request

    def initialize(*)
      super
      @body    = @env["rack.input"].clone.read
      @params  = ActiveSupport::HashWithIndifferentAccess.new(params)
      @headers = original_headers
    end

    def uri
      URI(base_url + fullpath)
    end

    def body
      @body
    end

    protected

    def original_headers
      {}.tap do |headers|
        env.select { |k, v| k.start_with?('HTTP_') }.each_pair do |k, v|
          header = k.sub(/^HTTP_/, '').split('_').map(&:capitalize).join('-')
          headers[header] = v
        end
      end
    end
  end
end
