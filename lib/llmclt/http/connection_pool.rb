# frozen_string_literal: true

module Llmclt
  class Http
    class ConnectionPool
      def initialize(max_size = 10)
        @max_size = max_size
      end

      def checkout(name)
        pool[name] ||= Connection.new(name: name, http: yield)

        conn = pool[name]
        conn.last_use = Time.now

        reduce if pool.size > @max_size

        conn.http
      end

      def shutdown
        pool.each_value(&:finish)
        Thread.current[:llmclt_connection] = nil
      end

      private

      def reduce
        conns = pool.values.sort_by(&:last_use)
        conns.first(pool.size - @max_size).each do |conn|
          conn.finish
          pool.delete(conn.name)
        end
      end

      def pool
        Thread.current[:llmclt_connection] ||= {}
        Thread.current[:llmclt_connection]
      end
    end
  end
end
