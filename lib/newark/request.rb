require 'active_support/hash_with_indifferent_access'

module Newark
  class Request < Rack::Request

    def uri
      URI(base_url + fullpath)
    end

    def params
      @params ||= ActiveSupport::HashWithIndifferentAccess.new(super)
    end

    def body
      @body ||= @env['rack.input'].read
    end

    def headers
      @headers ||= original_headers
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
