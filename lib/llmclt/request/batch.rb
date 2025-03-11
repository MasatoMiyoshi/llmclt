# frozen_string_literal: true

module Llmclt
  module Request
    class Batch < Base
      def endpoint_uri
        url = "https://#{@config.location_id}-aiplatform.googleapis.com/v1/projects/#{@config.project_id}/locations/#{@config.location_id}/batchPredictionJobs"
        url = "#{url}/#{@batch_job_id}" if @batch_job_id
        URI.parse(url)
      end

      def content
        if @batch_job_id
          request = Net::HTTP::Get.new(endpoint_uri.request_uri)
          @headers.each do |key, value|
            request[key] = value
          end
          request
        else
          super
        end
      end

      def build_response(response)
        Llmclt::Response::Batch.new(response)
      end

      private

      def build_request_json
        {
          name: @batch_job_name,
          displayName: @batch_job_name,
          model: "publishers/google/models/#{@config.model}",
          inputConfig: {
            instancesFormat: 'jsonl',
            gcsSource: {
              uris: @gcs_input_uri
            }
          },
          outputConfig: {
            predictionsFormat: 'jsonl',
            gcsDestination: {
              outputUriPrefix: @gcs_output_uri
            }
          }
        }.to_json
      end
    end
  end
end
