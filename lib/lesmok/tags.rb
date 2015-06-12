require 'liquid'

require 'lesmok/tags/error_logging'
require 'lesmok/tags/cached_include'
require 'lesmok/tags/erb_include'

module Lesmok
    module Tags

      def self.register_tags
        ::Liquid::Template.register_tag('erb_include',    ::Lesmok::Tags::ErbInclude)
        ::Liquid::Template.register_tag('cached_include', ::Lesmok::Tags::CachedInclude)
        ::Liquid::Template.register_tag('debug_comment',  ::Lesmok::Tags::DebugComment)
        ::Liquid::Template.register_tag('include',        ::Lesmok::Tags::DebugInclude) if Lesmok.config.debugging?
        ::Liquid::Template.register_tag('csrf',           ::Lesmok::Tags::Csrf)
      end

      class DebugComment < ::Liquid::Block
        include ErrorLogging
        def render(context)
          return '' unless Lesmok.config.debugging?
          with_exception_logging(context) do
            "<!-- LIQUID DEBUG: #{super} -->"
          end
        end
      end

      class DebugInclude < ::Liquid::Include
        include ErrorLogging
        def render(context)
          with_exception_logging(context) do
            result = super
            if context.errors.present?
              ::Lesmok.logger.debug " -- Liquid errors (#{context.errors.size}) seen in: #{@template_name}"
            end
            result
          end
        end
      end

      class Csrf < ::Liquid::Tag
        def render(context)
          controller  = context.registers[:controller]
          name        = controller.send(:request_forgery_protection_token).to_s
          value       = controller.send(:form_authenticity_token)
          %(<input type="hidden" name="#{name}" value="#{value}">)
        end
      end

  end
end
