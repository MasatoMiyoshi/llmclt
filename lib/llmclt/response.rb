# frozen_string_literal: true

module Llmclt
  class Response
    attr_reader :response

    def initialize(response_json)
      @response = JSON.parse(response_json)
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
