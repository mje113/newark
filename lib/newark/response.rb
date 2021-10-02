module Newark
  class Response < Rack::Response

    JSON_MIME_TYPE = 'application/json'.freeze

    def body=(value)
      value = if value.respond_to?(:to_str)
                header["Content-Type"] = "text/html;charset=utf8"   if  nil == headers["Content-Type"]
                [ value.to_str ]
              elsif value.respond_to?(:to_hash) && defined?(MultiJson)
                header['Content-Type'] = JSON_MIME_TYPE
                [ MultiJson.dump(value) ]
              elsif value.respond_to?(:to_ary)
                value
              else
                [ value ]
              end

      super value
    end
  end
end
