# frozen_string_literal: true

module Llmclt
  class Config
    class GenerationConfig
      # Generation configuration parameters
      # temperature: number
      # topP: number
      # topK: number
      # candidateCount: integer
      # maxOutputTokens: integer
      # presencePenalty: float
      # frequencyPenalty: float
      # stopSequences: [
      #   string
      # ]
      # responseMimeType: string
      # responseSchema: schema
      # seed: integer
      # responseLogprobs: boolean
      # logprobs: integer
      # audioTimestamp: boolean

      PARAMETERS = %i[
        temperature
        top_p
        top_k
        candidate_count
        max_output_tokens
        presence_penalty
        frequency_penalty
        stop_sequences
        response_mime_type
        response_schema
        seed
        response_logprobs
        logprobs
        audio_timestamp
      ].freeze

      def initialize(setting = {})
        @setting = setting
      end

      def build_request_content
        return {} if @setting.nil? || @setting.empty?

        config = PARAMETERS.each_with_object({}) do |param, cfg|
          p = param.to_s.camelize(:lower).to_sym
          cfg[p] = @setting[param] unless @setting[param].nil?
        end

        { generationConfig: config }
      end
    end
  end
end
