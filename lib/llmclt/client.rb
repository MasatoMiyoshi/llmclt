# frozen_string_literal: true

module Llmclt
  class Client
    def initialize(**kwargs)
      @config = Llmclt::Config.new(**kwargs)
      @request = Llmclt::Request.new(@config)
    end

    def request(prompt, stream: false, histories: [])
      @request.run(prompt, stream: stream, histories: histories)
    end

    def shutdown
      @request.shutdown
    end
  end
end
