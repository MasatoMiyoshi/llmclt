# frozen_string_literal: true

module Llmclt
  module Request
    module Chat
      private

      def build_request_json
        req = {}
        req.merge!(build_request_contents(@prompt, @histories))
        req.merge!(build_request_system_instruction)
        req.to_json
      end

      def build_request_contents(prompt, histories)
        content = { contents: [] }
        content.merge!(@config.safety_config.build_request_content)
        content.merge!(@config.generation_config.build_request_content)
        content[:contents].concat(build_request_history_contents(histories))
        content[:contents] << build_request_user_prompt(prompt)
        content
      end

      def build_request_history_contents(histories)
        histories.map do |history|
          {
            role: history[:role],
            parts: [{ text: history[:text] }]
          }
        end
      end

      def build_request_user_prompt(prompt)
        {
          role: 'user',
          parts: [
            {
              text: prompt
            }
          ]
        }
      end

      def build_request_system_instruction
        return {} if @config.system_instruction_prompt.nil? || @config.system_instruction_prompt.empty?

        {
          systemInstruction: {
            parts: [
              {
                text: @config.system_instruction_prompt
              }
            ]
          }
        }
      end
    end
  end
end
