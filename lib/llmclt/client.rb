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

    def batch_request(batch_job_name, gcs_input_uri, gcs_output_uri)
      @fetcher.batch_run(batch_job_name, gcs_input_uri, gcs_output_uri)
    end

    def batch_state_request(batch_job_id)
      @fetcher.batch_state_run(batch_job_id)
    end

    def shutdown
      @fetcher.shutdown
    end
  end
end
