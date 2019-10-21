module Async
  module Aws
    class HttpPlugin < ::Seahorse::Client::Plugin
      def add_handlers(handlers, config)
        handlers.add(::Async::Aws::HttpHandler, step: :send)
      end
    end
  end
end
