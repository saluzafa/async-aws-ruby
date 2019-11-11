module Async
  module Aws
    class ConnectionPool
      def initialize(connection_limit: nil)
        @clients = {}
        @connection_limit = connection_limit
      end

      def call(method, url, headers = [], body = nil)
        endpoint = ::Async::HTTP::Endpoint.parse(url)
        client = client_for(endpoint)

        request_body = \
          case body
          when ::Aws::Query::ParamList::IoWrapper
            ::Async::HTTP::Body::Buffered.wrap(body.instance_variable_get(:@io))
          else
            ::Async::HTTP::Body::Buffered.wrap(body)
          end
        request = ::Protocol::HTTP::Request.new(
          endpoint.scheme, endpoint.authority, method, endpoint.path, nil, headers,
          request_body
        )

        client.call(request)
      end

      def client_for(endpoint)
        @clients[endpoint] ||= ::Async::HTTP::Client.new(
          endpoint, endpoint.protocol, endpoint.scheme, endpoint.authority,
          retries: 3, connection_limit: @connection_limit
        )
      end

      def close
        @clients.each_value(&:close)
        @clients.clear
      end
    end
  end
end
