module Async
  module Aws
    class HttpHandler < ::Seahorse::Client::Handler
      def self.clients
        @clients ||= {}
      end

      def self.endpoints
        @endpoints ||= {}
      end

      def self.endpoint_for(url)
        endpoints[url.to_s] ||= Async::HTTP::Endpoint.parse(url.to_s)
      end

      def self.client_for(endpoint)
        clients[endpoint.hostname] ||= ::Async::HTTP::Client.new(
          endpoint,
          retries: 0,
          connection_limit: Async::Aws.connection_limit
        )
      end

      def call(context)
        req = context.http_request
        resp = context.http_response
        endpoint = self.class.endpoint_for(req.endpoint)

        begin
          client = self.class.client_for(endpoint)
          headers = ::Protocol::HTTP::Headers.new(
            req.headers.reject do |k, v|
              k == 'host' || k == 'content-length'
            end
          )
          buffered_body = Async::HTTP::Body::Buffered.wrap(req.body)
          request = ::Protocol::HTTP::Request.new(
            client.scheme, endpoint.authority, req.http_method, endpoint.path,
            nil, headers, buffered_body
          )
          response = client.call(request)
          body = response.read
          resp.signal_headers(response.status.to_i, response.headers.to_h)
          resp.signal_data(body)
          resp.signal_done
        rescue => error
          # not retried
          resp.signal_error(error)
        end

        Seahorse::Client::Response.new(context: context)
      end
    end
  end
end
