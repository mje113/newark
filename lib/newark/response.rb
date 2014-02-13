module Newark
  class Response < Rack::Response

    def body=(value)
      value = if value.respond_to?(:to_str)
                [ value.to_str ]
              else
                [ value ]
              end

      super value
    end
  end
end
