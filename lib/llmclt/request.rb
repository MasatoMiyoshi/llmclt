# frozen_string_literal: true

module Llmclt
  class Request
    def initialize(config)
      @config = config
      @pool = Llmclt::Http::ConnectionPool.new
    end

    def run(prompt, stream: false, histories: [])
      uri = request_uri(stream)
      request = build_request(uri, prompt, histories)
      http = checkout_http(uri)
      response = http.start { |h| h.request(request) }
      Llmclt::Response.new(response.body)
    end

    def shutdown
      @pool.shutdown
    end

    private

    def request_uri(stream)
      if stream
        URI.parse("#{endpoint_url}:streamGenerateContent")
      else
        URI.parse("#{endpoint_url}:generateContent")
      end
    end

    def endpoint_url
      "https://#{@config.location_id}-aiplatform.googleapis.com/v1/projects/#{@config.project_id}/locations/#{@config.location_id}/publishers/google/models/#{@config.model}"
    end

    def request_headers
      authorizer.apply({ 'Content-Type': 'application/json' })
    end

    def authorizer
      if @authorizer.nil? || @authorizer.expires_within?(60)
        @authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: StringIO.new(@config.service_account_json),
          scope: 'https://www.googleapis.com/auth/cloud-platform'
        )
        @authorizer.fetch_access_token!
      end
      @authorizer
    end

    def checkout_http(uri)
      @pool.checkout(pool_name(uri)) { build_http(uri) }
    end

    def pool_name(uri)
      "#{uri.scheme}_#{uri.host}_#{uri.port || uri.default_port}"
    end

    def build_http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = @config.open_timeout
      http.read_timeout = @config.read_timeout
      http.keep_alive_timeout = @config.keep_alive_timeout
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http
    end

    def build_request(uri, prompt, histories)
      request = Net::HTTP::Post.new(uri.request_uri)
      request_headers.each do |key, value|
        request[key] = value
      end
      request.body = build_request_json(prompt, histories)
      request
    end

    def build_request_json(prompt, histories)
      req = {}
      req.merge!(build_request_contents(prompt, histories))
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
