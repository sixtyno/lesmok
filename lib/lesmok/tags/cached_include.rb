require 'liquid'
require 'lesmok/caching/helpers'


module Lesmok
    module Tags

      class CachedInclude < ::Liquid::Include
        include ErrorLogging

        include ::Lesmok::Caching::Helpers
        include ExpiryCalculation
        extend  GlobalKeyHandling

        STALE_BREAD_KEY_SUFFIX = ':LESMOK-STALE-BREAD'

        def render(context)
          return super unless fragment_caching_enabled?
          cache_val = calculate_cache_key_for(context)

          return super unless cache_val.present?

          template_name = context[@template_name]

          expire_in = calculate_expiry(context[@attributes['cache_on']], context[@attributes['expire_in']])
          cache_key = self.class.full_cache_key_for(cache_val, template_name)
          cache_store = select_cache_store_for(context)

          result = perform_cached_inclusion_rendering_for(context, cache_store, cache_key) do
            super
          end
          lesmok_logger.debug "[#{self.class}] Lookup #{cache_key} in #{cache_store}..." if Lesmok.config.debugging?
          result = cache_store.fetch(cache_key, expires_in: expire_in) do
            lesmok_logger.debug "[#{self.class}] --- cache miss on #{cache_key} in #{cache_store}!" if Lesmok.config.debugging?
            rendered_str = super
            if Lesmok.config.serve_stale_content? && rendered_str.present?
              stale_cache_store = select_cache_store_for(context, :stale)
              stale_cache_store.set(cache_key + STALE_BREAD_KEY_SUFFIX, rendered_str, expires_in: nil)
            end
            rendered_str
          end

          if context.errors.present?
            lesmok_logger.debug "[lesmok] -- Liquid errors (#{context.errors.size}) seen in: #{template_name}"
          end

          result
        rescue Exception => err
          log_exception(err, context)
          if Lesmok.config.serve_stale_content? && cache_key.present?
            stale_cache_store = select_cache_store_for(context, :stale)
            stale = stale_cache_store.get(cache_key + STALE_BREAD_KEY_SUFFIX)
            lesmok_logger.warn "[lesmok] Serving stale content in: #{template_name}  [#{cache_key}]" if stale.present?
            stale
          else
            ""
          end
        end


        def perform_cached_inclusion_rendering_for(context, cache_store, cache_key) do
          lesmok_logger.debug "[#{self.class}] Lookup #{cache_key} in #{cache_store}..." if Lesmok.config.debugging?
          result = cache_store.fetch(cache_key, expires_in: expire_in) do
            lesmok_logger.debug "[#{self.class}] --- cache miss on #{cache_key} in #{cache_store}!" if Lesmok.config.debugging?
            rendered_str = yield
            if Lesmok.config.serve_stale_content? && rendered_str.present?
              stale_cache_store = select_cache_store_for(context, :stale)
              stale_cache_store.set(cache_key + STALE_BREAD_KEY_SUFFIX, rendered_str, expires_in: nil)
            end
            rendered_str
          end
          result
        end

        def calculate_cache_key_for(context)
          cached_on_obj = context[@attributes['cache_on']]
          cache_val = cached_on_obj && cached_on_obj.respond_to?(:cache_key) && cached_on_obj.cache_key
          cache_val ||= context[@attributes['cache_key']]

          ## Catch cases where cached_include is used incorrectly.
          if cache_val.blank?
            return error_calculating_cache_key(context, cached_on_obj)
          end
          ## Allow sub-scoping w/o manually creating cache key.
          cache_subscope = context[@attributes['cache_scope']]
          cache_val += ":SUBSCOPE-#{cache_subscope}" if cache_subscope.present?
          cache_val
        end

        def error_calculating_cache_key(context, cached_on_obj)
          template_name = context[@template_name]
          if Lesmok.config.debugging?
            lesmok_logger.warn "[#{self.class}] No valid cache key given for '#{template_name}' template!"
            lesmok_logger.debug " -- No cache key given nor found for object: #{cached_on_obj.inspect.truncate(64)}"
          end
          if Lesmok.config.raise_errors?
            raise ArgumentError.new("No valid cache key! given for '#{template_name}' template!")
          end
          nil
        end

        def select_cache_store_for(context, fallback_store_name = nil)
          cache_store_name = context[@attributes['cache_store']] || fallback_store_name
          cache_store = Lesmok.config.find_cache_store(cache_store_name)
        end

        def fragment_caching_enabled?
          Lesmok.config.caching?
        end
        def lesmok_logger
          ::Lesmok.logger
        end
      end

    end
end
