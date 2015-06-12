require 'active_support'
module Lesmok
  module Caching
    module Helpers

      module ExpiryCalculation
        def calculate_expiry(cached_on_obj = nil, expire_in_option = nil, jitter_factor = 0.05)
          expire_in ||= cached_on_obj && cached_on_obj.respond_to?(:cache_expire_in) && cached_on_obj.cache_expire_in
          expire_in ||= (expire_in_option || 5).to_i * 60  # TODO: Is option authorative or fallback only?
          expire_in += rand * expire_in * jitter_factor if jitter_factor  # 5 % random additional time to avoid all expiring at once.
          expire_in
        end
        extend self
      end
      module GlobalKeyHandling
        def global_cache_scope
          "Lesmok:Liquid"
        end
        def full_cache_key_for(cached_on_obj, template_name, global_scope = nil)
          cache_val = cached_on_obj.to_s if cached_on_obj.kind_of?(String)
          cache_val ||= cached_on_obj.respond_to?(:cache_key) && cached_on_obj.cache_key
          "#{global_scope || global_cache_scope}:#{I18n.locale}:cached_include:#{template_name}:#{cache_val}"
        end
        extend self
      end

    end
  end
end
