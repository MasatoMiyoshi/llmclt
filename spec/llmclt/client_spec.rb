# frozen_string_literal: true

RSpec.describe Llmclt::Client do
  let!(:project_id) { 'aaa-bbb-123456' }
  let!(:location_id) { 'asia-northeast1' }
  let!(:model) { 'gemini-1.5-pro-001' }
  let!(:service_account_json) { File.read('spec/fixtures/service_account.json') }
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
  end

  after do
    client.shutdown
    client_with_config.shutdown
  end

  describe '#request' do
    let!(:prompt) { 'Hello! How are you?' }
    let!(:histories) do
      [
        { role: 'user', text: 'This is Tom.' },
        { role: 'model', text: 'OK!' }
      ]
    end

    before do
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

    context 'when stream is true' do
      it 'gets a response' do
        response = client.request(prompt, stream: true)
        expect(response.success?).to be(true)
        expect(response.text).to eq("I'm Fine.")
      end
    end

    context 'when stream is false' do
      it 'gets a response' do
        response = client.request(prompt)
        expect(response.success?).to be(true)
        expect(response.text).to eq("I'm Fine.")
      end
    end

    context 'when multi-turn conversations' do
      it 'gets a response' do
        response = client.request(prompt, histories: histories)
        expect(response.success?).to be(true)
        expect(response.text).to eq("I'm Fine.")
      end
    end

    context 'when setting a system instruction' do
      it 'gets a response' do
        response = client_with_config.request(prompt)
        expect(response.success?).to be(true)
        expect(response.text).to eq("I'm Fine.")
      end
    end
  end

  describe '#chat_jsonl' do
    let!(:prompts) { ['Hello! How are you?', 'This is Tom.'] }
    let!(:expected_jsonl) { File.read('spec/fixtures/gemini_request.jsonl') }

    it 'gets a response' do
      jsonl = client.chat_jsonl(prompts)
      expect(jsonl).to eq(expected_jsonl)
    end
  end

  describe '#batch_request' do
    let!(:batch_job_name) { 'BATCH_JOB_NAME' }
    let!(:gcs_input_uri) { 'gs://bucketname/sample/file.jsonl' }
    let!(:gcs_output_uri) { 'gs://bucketname/sample' }

    before do
      stub_request(:post, "https://#{location_id}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location_id}/batchPredictionJobs")
        .with(headers: { 'Content-type': 'application/json' })
        .to_return(
          headers: { 'Content-Type' => 'application/json' },
          body: File.read('spec/fixtures/gemini_batch_response.json')
        )
    end

    it 'gets a response' do
      response = client.batch_request(batch_job_name, gcs_input_uri, gcs_output_uri)
      expect(response.success?).to be(true)
      expect(response.batch_job_id).to eq('BATCH_JOB_ID')
      expect(response.state).to eq('JOB_STATE_PENDING')
    end
  end

  describe '#batch_state_request' do
    let!(:batch_job_id) { 'BATCH_JOB_ID' }

    before do
      stub_request(:get, "https://#{location_id}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location_id}/batchPredictionJobs/#{batch_job_id}")
        .with(headers: { 'Content-type': 'application/json' })
        .to_return(
          headers: { 'Content-Type' => 'application/json' },
          body: File.read('spec/fixtures/gemini_batch_response.json')
        )
    end

    it 'gets a response' do
      response = client.batch_state_request(batch_job_id)
      expect(response.success?).to be(true)
      expect(response.state_succeeded?).to eq(false)
    end
  end
end
