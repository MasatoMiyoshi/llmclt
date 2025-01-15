# frozen_string_literal: true

module Llmclt
  class Config
    DEFAULT_CONFIGS = {
      project_id: nil,
      location_id: 'asia-northeast1',
      model: 'gemini-1.5-pro-001',
      service_account_json: nil,
      system_instruction_prompt: nil,
      open_timeout: 60,
      read_timeout: 60,
      keep_alive_timeout: 15
    }.freeze

    attr_accessor(*DEFAULT_CONFIGS.keys)
    attr_accessor :safety_config
    attr_accessor :generation_config

    def initialize(**kwargs)
      DEFAULT_CONFIGS.each do |key, value|
        send(:"#{key}=", kwargs[key] || value)
      end

      self.safety_config = Llmclt::Config::SafetyConfig.new(kwargs[:safety_settings])
      self.generation_config = Llmclt::Config::GenerationConfig.new(kwargs[:generation_config])
    end
  end
end
