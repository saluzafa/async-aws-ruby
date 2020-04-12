require 'async/http'
require 'async/aws/http_handler'
require 'async/aws/http_plugin'

module Async
  module Aws
    module_function

    def config
      @config ||= {}
    end

    def configure(hash)
      config.merge!(hash.slice(:connection_limit))
    end

    def set(key, value)
      __send__("#{key}=".to_sym, value)
    end

    def connection_limit=(arg)
      config[:connection_limit] = arg.to_i
    end

    def connection_limit
      config.fetch(:connection_limit, 1)
    end
  end
end
