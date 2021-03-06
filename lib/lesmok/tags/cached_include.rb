require 'liquid'
require 'lesmok/caching/helpers'


module Lesmok
    module Tags

      class CachedInclude < ::Liquid::Include
        include ErrorLogging

        include ::Lesmok::Caching::Helpers
        include ExpiryCalculation
        extend  GlobalKeyHandling

        def render(context)
          return super unless fragment_caching_enabled?
          cached_on_obj = context[@attributes['cache_on']]
          cache_val = cached_on_obj && cached_on_obj.respond_to?(:cache_key) && cached_on_obj.cache_key
          cache_val ||= context[@attributes['cache_key']]

          template_name = context[@template_name]

          ## Catch cases where cached_include is used incorrectly.
          if cache_val.blank?
            if Lesmok.config.debugging?
              Lesmok.logger.warn "[#{self.class}] No valid cache key given for '#{template_name}' template!"
              Lesmok.logger.debug " -- No cache key given nor found for object: #{cached_on_obj.inspect.truncate(64)}"
            end
            if Lesmok.config.raise_errors?
              raise ArgumentError.new("No valid cache key! given for '#{template_name}' template!")
            end
          end

          return super unless cache_val.present?

          ## Allow sub-scoping w/o manually creating cache key.
          cache_subscope = context[@attributes['cache_scope']]
          cache_val += ":SUBSCOPE-#{cache_subscope}" if cache_subscope.present?

          expire_in = calculate_expiry(cached_on_obj, context[@attributes['expire_in']])
          cache_key = self.class.full_cache_key_for(cache_val, template_name)
          cache_store = select_cache_store_for(context)
          Lesmok.logger.debug "[#{self.class}] Lookup #{cache_key} in #{cache_store}..." if Lesmok.config.debugging?
          result = cache_store.fetch(cache_key, expires_in: expire_in) do
            Lesmok.logger.debug "[#{self.class}] --- cache miss on #{cache_key} in #{cache_store}!" if Lesmok.config.debugging?
            super
          end

          if context.errors.present?
            ::Lesmok.logger.debug " -- Liquid errors (#{context.errors.size}) seen in: #{@template_name}"
          end

          result
        rescue Exception => err
          log_exception(err, context)
          ""
        end

        def select_cache_store_for(context)
          cache_store_name = context[@attributes['cache_store']]
          cache_store = Lesmok.config.find_cache_store(cache_store_name)
        end

        def fragment_caching_enabled?
          Lesmok.config.caching?
        end
      end

    end
end
