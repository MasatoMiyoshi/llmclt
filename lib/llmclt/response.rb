# frozen_string_literal: true

module Llmclt
  class Response
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
      status >= 400 && status <= 599
    end

    def text
      texts.join
    end

    def texts
      candidates = responses.map { |res| res['candidates'] }.flatten
      parts = candidates.map { |candidate| candidate['content']['parts'] }.flatten
      parts.map { |part| part['text'] }
    end

    def stream?
      response.is_a?(Array)
    end

    private

    def responses
      stream? ? response : [response]
    end
  end
end
