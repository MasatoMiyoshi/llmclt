# frozen_string_literal: true

RSpec.describe Llmclt::Config::SafetyConfig do
  describe '#build_request_content' do
    let!(:args) do
      [
        {
          category: 'HARM_CATEGORY_DANGEROUS_CONTENT',
          threshold: 'BLOCK_LOW_AND_ABOVE'
        }
      ]
    end
    let!(:content) do
      {
        safetySettings: [
          {
            category: 'HARM_CATEGORY_DANGEROUS_CONTENT',
            threshold: 'BLOCK_LOW_AND_ABOVE'
          }
        ]
      }
    end

    it 'builds contents' do
      config = described_class.new(args)
      expect(config.build_request_content).to eq(content)
    end
  end
end
