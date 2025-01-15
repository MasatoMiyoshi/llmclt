# frozen_string_literal: true

module Llmclt
  class Config
    class SafetyConfig
      # SafetySettings parameters
      # category: enum
      # HARM_CATEGORY_SEXUALLY_EXPLICIT
      # HARM_CATEGORY_HATE_SPEECH
      # HARM_CATEGORY_HARASSMENT
      # HARM_CATEGORY_DANGEROUS_CONTENT
      # threshold: enum
      # OFF
      # BLOCK_NONE
      # BLOCK_LOW_AND_ABOVE
      # BLOCK_MEDIUM_AND_ABOVE
      # BLOCK_ONLY_HIGH

      PARAMETERS = %i[category threshold].freeze

      def initialize(settings = [])
        @settings = settings
      end

      def build_request_content
        return {} if @settings.nil? || @settings.empty?

        {
          safetySettings: @settings.map do |setting|
            PARAMETERS.each_with_object({}) do |param, cfg|
              p = param.to_s.camelize(:lower).to_sym
              cfg[p] = setting[param] unless setting[param].nil?
            end
          end
        }
      end
    end
  end
end
