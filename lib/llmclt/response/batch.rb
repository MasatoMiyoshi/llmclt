# frozen_string_literal: true

module Llmclt
  module Response
    class Batch < Base
      def batch_job_id
        @response['name'].split('/').last
      end

      def state
        @response['state']
      end

      def state_succeeded?
        @response['state'] == 'JOB_STATE_SUCCEEDED'
      end
    end
  end
end
