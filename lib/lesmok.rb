require 'lesmok/version'
require 'lesmok/config'
require 'lesmok/tags'
require 'lesmok/acid'
require 'lesmok/backwards_compatibility'

module Lesmok
  module ClassMethods
    def config
      @configuration ||= Config.new
    end
    def configure
      yield(config)
    end
    def logger
      config.logger
    end
  end
  extend ClassMethods
end
