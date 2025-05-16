# frozen_string_literal: true

module Llmclt
  module Response
    class Base
      attr_reader :response_orig, :response

      def initialize(response)
        @response_orig = response
        @response = JSON.parse(response.body) if response.body
      rescue JSON::ParserError
        @response = nil
      end

      def status
        response_orig.code.to_i
      end

      def success?
        status == 200
      end

      def error?
        status.between?(400, 599)
      end
    end
  end
end
