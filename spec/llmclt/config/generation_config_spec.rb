# frozen_string_literal: true

RSpec.describe Llmclt::Config::GenerationConfig do
  describe '#build_request_content' do
    let!(:args) do
      {
        temperature: 1.0,
        top_p: 0.95
      }
    end
    let!(:content) do
      {
        generationConfig: {
          temperature: 1.0,
          topP: 0.95
        }
      }
    end

    it 'builds contents' do
      config = described_class.new(args)
      expect(config.build_request_content).to eq(content)
    end
  end
end
