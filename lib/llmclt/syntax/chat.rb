# frozen_string_literal: true

module Llmclt
  module Syntax
    class Chat
      attr_reader :prompts, :config, :histories
      attr_reader :params

      def initialize(prompts, config, histories: [])
        @prompts = Array(prompts)
        @config = config
        @histories = histories
        @params = build_params
      end

      def to_json(*_args)
        params.size == 1 ? params.first.to_json : params.to_json
      end

      def to_jsonl
        params.map { |json| { request: json } }.map(&:to_json).join("\n")
      end

      private

      def build_params
        prompts.each_with_object([]) do |prompt, prms|
          prm = {}
          prm.merge!(build_contents(prompt))
          prm.merge!(build_system_instruction)
          prms << prm
        end
      end

      def build_contents(prompt)
        content = { contents: [] }
        content.merge!(config.safety_config.build_request_content)
        content.merge!(config.generation_config.build_request_content)
        content[:contents].concat(build_history_contents(histories))
        content[:contents] << build_user_prompt(prompt)
        content
      end

      def build_history_contents(histories)
        histories.map do |history|
          {
            role: history[:role],
            parts: [{ text: history[:text] }]
          }
        end
      end

      def build_user_prompt(prompt)
        {
          role: 'user',
          parts: [
            {
              text: prompt
            }
          ]
        }
      end

      def build_system_instruction
        return {} if config.system_instruction_prompt.nil? || config.system_instruction_prompt.empty?

        {
          systemInstruction: {
            parts: [
              {
                text: config.system_instruction_prompt
              }
            ]
          }
        }
      end
    end
  end
end
