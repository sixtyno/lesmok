module Lesmok
  class Config
    attr_accessor :logger
    attr_accessor :cache
    attr_accessor :caching_enabled
    attr_accessor :serve_stale_content
    attr_accessor :available_cache_stores
    attr_accessor :debugging_enabled
    attr_accessor :raise_errors_enabled

    alias :raise_errors? :raise_errors_enabled
    alias :debugging? :debugging_enabled

    def logger
      @logger ||= (rails? && ::Rails.logger)
    end

    def cache
      @cache ||= find_cache_store(:default) || (rails? && ::Rails.cache) || nil
    end

    def caching?
      check_dynamically_toggleable_setting(@caching_enabled)
    end

    def serve_stale_content?
      check_dynamically_toggleable_setting(@serve_stale_content)
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


    protected

    ##
    # Some settings can be changed at run-time from other parts of the system.
    # Allow setting a `proc` to check this each time.
    #
    def check_dynamically_toggleable_setting(toggleable)
      return false if !toggleable
      toggleable.kind_of?(Proc) ? toggleable.call : true
    end

  end
end
