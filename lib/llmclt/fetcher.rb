# frozen_string_literal: true

module Llmclt
  class Fetcher
    def initialize(config)
      @config = config
      @pool = Llmclt::Http::ConnectionPool.new
    end

    def run(prompt, stream: false, histories: [])
      request = build_request(
        request_mode(stream),
        request_headers,
        @config,
        prompt,
        histories
      )
      request_http(request)
    end

    def batch_run(batch_job_name, gcs_input_uri, gcs_output_uri)
      request = Llmclt::Request::Batch.new(
        request_headers,
        @config,
        batch_job_name: batch_job_name,
        gcs_input_uri: gcs_input_uri,
        gcs_output_uri: gcs_output_uri
      )
      request_http(request)
    end

    def batch_state_run(batch_job_id)
      request = Llmclt::Request::Batch.new(
        request_headers,
        @config,
        batch_job_id: batch_job_id
      )
      request_http(request)
    end

    def shutdown
      @pool.shutdown
    end

    private

    def request_http(request)
      http = checkout_http(request.endpoint_uri)
      response = http.start { |h| h.request(request.content) }
      request.build_response(response)
    end

    def request_mode(stream)
      if stream
        'streaming'
      else
        'non_streaming'
      end
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

    def build_request(request_mode, request_headers, config, prompt, histories)
      case request_mode
      when 'streaming'
        Llmclt::Request::Streaming.new(
          request_headers, config,
          prompt: prompt,
          histories: histories
        )
      when 'non_streaming'
        Llmclt::Request::NonStreaming.new(
          request_headers, config,
          prompt: prompt,
          histories: histories
        )
      else
        raise NameError, "#{request_mode} is an invalid request mode"
      end
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
  end
end
