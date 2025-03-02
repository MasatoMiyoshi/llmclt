# frozen_string_literal: true

module Llmclt
  module Response
    module Chat
      def text
        texts.join
      end

      def texts
        raise NotImplementedError, "#{class_name}#{__method__} is not implemented"
      end
    end
  end
end
