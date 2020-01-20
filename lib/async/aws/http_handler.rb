module Async
  module Aws
    class HttpHandler < ::Seahorse::Client::Handler
      def self.clients
        @clients ||= {}
      end

      def self.with_configuration(**kwargs)
        Class.new(self).tap do |klass|
          klass.connection_pool_size = kwargs.fetch(
            :connection_pool_size, Async::Aws.connection_pool_size
          )
          klass.keep_alive_timeout = kwargs.fetch(
            :keep_alive_timeout, Async::Aws.keep_alive_timeout
          )
        end
      end

      def self.connection_pool_size
        @connection_pool_size ||= Async::Aws.connection_pool_size
      end

      def self.connection_pool_size=(value)
        @connection_pool_size = value.to_i
      end

      def self.keep_alive_timeout
        @keep_alive_timeout ||= Async::Aws.keep_alive_timeout
      end

      def self.keep_alive_timeout=(value)
        @keep_alive_timeout = value.to_i
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
        self.class.clients[endpoint.hostname] ||= ::Async::Aws::HttpClient.new(
          endpoint,
          pool_size: self.class.connection_pool_size,
          keep_alive_timeout: self.class.keep_alive_timeout
        )
      end
    end
  end
end
