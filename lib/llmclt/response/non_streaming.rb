# frozen_string_literal: true

module Llmclt
  module Response
    class NonStreaming < Base
      include Llmclt::Response::Chat

      def texts
        candidates = response['candidates']
        parts = candidates.map { |candidate| candidate['content']['parts'] }.flatten
        parts.map { |part| part['text'] }
      end
    end
  end
end
