require 'async/http'
require 'async/http/internet'
require 'async/aws/http_client'
require 'async/aws/http_handler'
require 'async/aws/http_plugin'

module Async
  module Aws
    module_function

    def keep_alive_timeout=(arg)
      @keep_alive_timeout = arg.to_i
    end

    def keep_alive_timeout
      @keep_alive_timeout || 2
    end

    def connection_pool_size=(arg)
      @connection_pool_size = arg.to_i
    end

    def connection_pool_size
      @connection_pool_size || 1
    end

    def configure(&block)
      instance_exec(&block)
    end
  end
end
