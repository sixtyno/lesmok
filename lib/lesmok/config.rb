module Lesmok
  class Config
    attr_accessor :logger
    attr_accessor :cache
    attr_accessor :caching_enabled
    attr_accessor :serve_stale_content
    attr_accessor :available_cache_stores
    attr_accessor :debugging_enabled
    attr_accessor :raise_errors_enabled

    alias :serve_stale_content? :serve_stale_content
    alias :raise_errors? :raise_errors_enabled
    alias :debugging? :debugging_enabled

    def logger
      @logger ||= (rails? && ::Rails.logger)
    end

    def cache
      @cache ||= find_cache_store(:default) || (rails? && ::Rails.cache) || nil
    end

    def caching?
      return false if !@caching_enabled
      @caching_enabled.kind_of?(Proc) ? @caching_enabled.call : true
    end

    def find_cache_store(name = nil)
      name  ||= :default
      avail_stores = (available_cache_stores || {})
      store   = avail_stores[name.to_sym]
      store ||= avail_stores[:default]
      store ||= cache
    end

    def rails?
      Object.const_defined? "Rails"
    end

  end
end
