# frozen_string_literal: true

require 'async/io/endpoint'
require 'async/io/stream'
require 'protocol/http/body/streamable'
require 'protocol/http/methods'

module Async
  module Aws
    class HttpClient < ::Protocol::HTTP::Methods
      attr_accessor :keep_alive_timeout
      attr_reader   :scheme

      ConnectionSpec = Struct.new(:connection, :used_at)

      # Provides a robust interface to a server.
      # * If there are no connections, it will create one.
      # * If there are already connections, it will reuse it.
      # * If a request fails, it will retry it up to N times if it was idempotent.
      # The client object will never become unusable. It internally manages persistent connections (or non-persistent connections if that's required).
      # @param endpoint [Endpoint] the endpoint to connnect to.
      # @param protocol [Protocol::HTTP1 | Protocol::HTTP2 | Protocol::HTTPS] the protocol to use.
      # @param scheme [String] The default scheme to set to requests.
      # @param authority [String] The default authority to set to requests.
      def initialize(endpoint, pool_size: 2, keep_alive_timeout: 5)
        @endpoint = endpoint
        @protocol = endpoint.protocol
        @scheme = endpoint.scheme
        @authority = endpoint.authority
        @keep_alive_timeout = keep_alive_timeout
        @clock_gettime_constant = \
          if defined?(Process::CLOCK_MONOTONIC)
            Process::CLOCK_MONOTONIC
          else
            Process::CLOCK_REALTIME
          end
        @pool = make_pool(pool_size)
      end

      def close
        until @pool.empty?
          connection_spec = @pool.dequeue
          connection_spec.connection.close
        end
      end

      def call(request)
        request.scheme ||= self.scheme
        request.authority ||= self.authority

        attempt = 0

        # We may retry the request if it is possible to do so. https://tools.ietf.org/html/draft-nottingham-httpbis-retry-01 is a good guide for how retrying requests should work.
        begin
          attempt += 1

          # As we cache pool, it's possible these pool go bad (e.g. closed by remote host). In this case, we need to try again. It's up to the caller to impose a timeout on this. If this is the last attempt, we force a new connection.
          connection_spec = @pool.dequeue
          if connection_spec.used_at + keep_alive_timeout <= current_time
            connection_spec.connection.close
            connection_spec = create_connection_spec
          end

          # send request
          response = request.call(connection_spec.connection)

          # The connection won't be released until the body is completely read/released.
          ::Protocol::HTTP::Body::Streamable.wrap(response) do
            connection_spec.used_at = current_time
            @pool << connection_spec
          end

          return response
        rescue => e
          @pool << connection_spec if connection_spec
          raise e
        end
      end

      private

      def current_time
        Process.clock_gettime(@clock_gettime_constant)
      end

      def create_connection_spec
        ConnectionSpec.new(
          @protocol.client(@endpoint.connect),
          current_time
        )
      end

      def make_pool(size)
        Async::Queue.new.tap do |queue|
          size.times do
            queue << create_connection_spec
          end
        end
      end
    end
  end
end
