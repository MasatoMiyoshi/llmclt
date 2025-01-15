# frozen_string_literal: true

module Llmclt
  class Http
    class Connection
      attr_accessor :name, :http, :last_use

      def initialize(**kwargs)
        @name = kwargs[:name]
        @http = kwargs[:http]
        @last_use = kwargs[:last_use]
      end

      def finish
        http.finish if http&.started?
      end
    end
  end
end
