module Async
  module Aws
    class HttpHandler < ::Seahorse::Client::Handler
      def initialize(handler = nil)
        super(handler)
        @clients = {}
      end

      def call(context)
        req = context.http_request
        resp = context.http_response
        endpoint = Async::HTTP::Endpoint.parse(req.endpoint.to_s)

        begin
          client = client_for(endpoint)
          headers_arr = req.headers.reject do |k, v|
            k == 'host' || k == 'content-length'
          end
          buffered_body = Async::HTTP::Body::Buffered.wrap(req.body)
          request = ::Protocol::HTTP::Request.new(
            client.scheme, endpoint.authority, req.http_method, endpoint.path,
            nil, headers_arr, buffered_body
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

      def client_for(endpoint)
        @clients[endpoint.hostname] ||= ::Async::Aws::HttpClient.new(
          endpoint,
          pool_size: Async::Aws.connection_pool_size,
          keep_alive_timeout: Async::Aws.keep_alive_timeout
        )
      end
    end
  end
end
