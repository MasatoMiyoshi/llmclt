# frozen_string_literal: true

module Llmclt
  module Response
    class Streaming < Base
      include Llmclt::Response::Chat

      def texts
        candidates = response.map { |res| res['candidates'] }.flatten
        parts = candidates.map { |candidate| candidate['content']['parts'] }.flatten
        parts.map { |part| part['text'] }
      end
    end
  end
end
