# frozen_string_literal: true

module Llmclt
  module Request
    class Base
      def initialize(headers, config, **kwargs)
        @headers = headers
        @config = config
        kwargs.each { |k, v| instance_variable_set(:"@#{k}", v) }
      end

      def endpoint_uri
        raise NotImplementedError, "#{class_name}#{__method__} is not implemented"
      end

      def content
        request = Net::HTTP::Post.new(endpoint_uri.request_uri)
        @headers.each do |key, value|
          request[key] = value
        end
        request.body = build_request_json
        request
      end

      def build_response(response)
        raise NotImplementedError, "#{class_name}#{__method__} is not implemented"
      end

      private

      def endpoint_host
        if @config.location_id == 'global'
          'aiplatform.googleapis.com'
        else
          "#{@config.location_id}-aiplatform.googleapis.com"
        end
      end

      def build_request_json
        raise NotImplementedError, "#{class_name}#{__method__} is not implemented"
      end
    end
  end
end
