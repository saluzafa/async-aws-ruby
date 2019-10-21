require 'async/http'
require 'async/http/internet'
require 'async/aws/connection_pool'
require 'async/aws/http_handler'
require 'async/aws/http_plugin'

module Async
  module Aws
    module_function

    def connection_pool=(arg)
      @connection_pool = arg
    end

    def connection_pool
      @connection_pool ||= ConnectionPool.new
    end
  end
end
