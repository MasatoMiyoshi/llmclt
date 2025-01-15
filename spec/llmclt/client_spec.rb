# frozen_string_literal: true

RSpec.describe Llmclt::Client do
  describe '#request' do
    let!(:project_id) { 'aaa-bbb-123456' }
    let!(:location_id) { 'asia-northeast1' }
    let!(:model) { 'gemini-1.5-pro-001' }
    let!(:service_account_json) { File.read('spec/fixtures/service_account.json') }
    let!(:prompt) { 'Hello! How are you?' }
    let!(:histories) do
      [
        { role: 'user', text: 'This is Tom.' },
        { role: 'model', text: 'OK!' }
      ]
    end
    let!(:client) do
      described_class.new(
        project_id: project_id,
        location_id: location_id,
        model: model,
        service_account_json: service_account_json
      )
    end
    let!(:client_with_config) do
      described_class.new(
        project_id: project_id,
        location_id: location_id,
        model: model,
        service_account_json: service_account_json,
        system_instruction_prompt: "I'm a helpful assistant.",
        safety_settings: [
          {
            category: 'HARM_CATEGORY_DANGEROUS_CONTENT',
            threshold: 'BLOCK_LOW_AND_ABOVE'
          }
        ],
        generation_config: {
          temperature: 1.0,
          top_p: 0.95
        }
      )
    end

    before do
      stub_request(:post, 'https://www.googleapis.com/oauth2/v4/token')
        .to_return(
          headers: { 'Content-Type' => 'application/json' },
          body: File.read('spec/fixtures/oauth2_response.json')
        )

      stub_request(:post, "https://#{location_id}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location_id}/publishers/google/models/#{model}:generateContent")
        .with(headers: { 'Content-type': 'application/json' })
        .to_return(
          headers: { 'Content-Type' => 'application/json' },
          body: File.read('spec/fixtures/gemini_response.json')
        )

      stub_request(:post, "https://#{location_id}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location_id}/publishers/google/models/#{model}:streamGenerateContent")
        .with(headers: { 'Content-type': 'application/json' })
        .to_return(
          headers: { 'Content-Type' => 'application/json' },
          body: File.read('spec/fixtures/gemini_stream_response.json')
        )
    end

    after do
      client.shutdown
      client_with_config.shutdown
    end

    context 'when stream is true' do
      it 'gets a response' do
        response = client.request(prompt, stream: true)
        expect(response.text).to eq("I'm Fine.")
      end
    end

    context 'when stream is false' do
      it 'gets a response' do
        response = client.request(prompt)
        expect(response.text).to eq("I'm Fine.")
      end
    end

    context 'when multi-turn conversations' do
      it 'gets a response' do
        response = client.request(prompt, histories: histories)
        expect(response.text).to eq("I'm Fine.")
      end
    end

    context 'when setting a system instruction' do
      it 'gets a response' do
        response = client_with_config.request(prompt)
        expect(response.text).to eq("I'm Fine.")
      end
    end
  end
end
