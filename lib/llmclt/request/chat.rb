# frozen_string_literal: true

module Llmclt
  module Request
    module Chat
      private

      def build_request_json
        Llmclt::Syntax::Chat.new(@prompt, @config, histories: @histories).to_json
      end
    end
  end
end
