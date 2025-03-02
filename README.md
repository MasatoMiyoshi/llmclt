# Llmclt

A simple client for [Gemini API](https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/inference).

For an authentication, this gem uses a service account json file.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'llmclt'
```

And then run:

```
$ bundle install
```

Or install it yourself as:

```shell
$ gem install llmclt
```

## Usage

Use as follows:

```ruby
client = Llmclt::Client.new(
  project_id: project_id,
  location_id: location_id,
  model: model,
  service_account_json: service_account_json
)

prompt = 'Hello. This is Tom!. How are you?'

response = client.request(prompt)
response.text

client.shutdown
```

### System instruction

```ruby
client = Llmclt::Client.new(
  project_id: project_id,
  location_id: location_id,
  model: model,
  service_account_json: service_account_json,
  system_instruction_prompt: 'You are a helpful assistant.'
)

prompt = 'Hello. This is Tom!. How are you?'

response = client.request(prompt)
response.text

client.shutdown
```

### Stream mode

```ruby
response = client.request(prompt, stream: true)
response.text
```

### Multi turn

```ruby
histories = [
  { role: 'user', text: 'Hello! This is Tom.' },
  { role: 'model', text: 'Hello, Tom. Can I help you?' }
]
prompt = 'Do you know my name?'
response = client.request(prompt, histories: histories)
response.text
```

### Output JSON Lines format

```ruby
client = Llmclt::Client.new()
prompt = [
  'Hello. This is Tom!. How are you?',
  'Do you know my name?'
]
client.chat_jsonl(prompts)
```
then, it outputs JSON Lines like as follows:
```json
{"request":{"contents": [{"role": "user", "parts": [{"text": "Hello. This is Tom!. How are you?"}]}]}}
{"request":{"contents": [{"role": "user", "parts": [{"text": "Do you know my name?"}]}]}}
```

### Batch mode

```ruby
client = Llmclt::Client.new(
  project_id: project_id,
  location_id: location_id,
  model: model,
  service_account_json: service_account_json
)
batch_job_name = 'BATCH_JOB_NAME'
gcs_input_uri = 'gs://BUCKET_NAME/file.jsonl'
gcs_output_uri = 'gs://BUCKET_NAME/'
response = client.batch_request(batch_job_name, gcs_input_uri, gcs_output_uri)
response.state
=> 'JOB_STATE_PENDING'
response.batch_job_id
=> 'BATCH_JOB_ID'
```
then, you can poll for the status of the batch job using the `BATCH_JOB_ID` like as follows:
```ruby
response = client.batch_state_request('BATCH_JOB_ID')
response.state
=> 'JOB_STATE_SUCCEEDED'
```

### Configuration

```ruby
client = Llmclt::Client.new(
  project_id: project_id,
  location_id: location_id,
  model: model,
  service_account_json: service_account_json,
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
```

Refer [the API references](https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/inference) for configuration.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MasatoMiyoshi/llmclt. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/MasatoMiyoshi/llmclt/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Llmclt project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/MasatoMiyoshi/llmclt/blob/main/CODE_OF_CONDUCT.md).
