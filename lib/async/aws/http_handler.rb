module Async
  module Aws
    class HttpHandler < ::Seahorse::Client::Handler
      def call(context)
        req = context.http_request
        resp = context.http_response

        begin
          headers_arr = req.headers.reject do |k, v|
            k == 'host' || k == 'content-length'
          end
          response = Async::Aws.connection_pool.call(
            req.http_method, req.endpoint.to_s, headers_arr, req.body
          )
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
