# frozen_string_literal: true

RSpec.describe Llmclt::Config do
  describe '#initialize' do
    it 'initializes a instance' do
      config = described_class.new(system_instruction_prompt: "I'm a helpful assistant.")
      expect(config.system_instruction_prompt).to eq("I'm a helpful assistant.")
    end
  end
end
