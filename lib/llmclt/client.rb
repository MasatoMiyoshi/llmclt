# frozen_string_literal: true

module Llmclt
  class Client
    def initialize(**kwargs)
      @config = Llmclt::Config.new(**kwargs)
      @fetcher = Llmclt::Fetcher.new(@config)
    end

    def request(prompt, stream: false, histories: [])
      @fetcher.run(prompt, stream: stream, histories: histories)
    end

    def chat_jsonl(prompts, histories: [])
      Llmclt::Syntax::Chat.new(prompts, @config, histories: histories).to_jsonl
    end

    def shutdown
      @fetcher.shutdown
    end
  end
end
