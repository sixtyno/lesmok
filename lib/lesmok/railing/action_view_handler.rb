##
#
# To register for use in Rails:
#   ActionView::Template.register_template_handler :liquid, ::Lesmok::Railing::ActionViewHandler'
#
# Based on example by Roy van der Meij:
# - http://royvandermeij.com/blog/2011/09/21/create-a-liquid-handler-for-rails-3-dot-1/
#
module Lesmok
  module Railing

    class ActionViewHandler
      def self.lesmok_options
        @lesmok_options ||= {}
      end

      def self.call(template)
        "#{self}.new(self).render(#{template.source.inspect}, local_assigns)"
      end

      def initialize(view)
        @view = view
      end

      def render(template, local_assigns = {})
        @view.controller.headers["Content-Type"] ||= 'text/html; charset=utf-8'

        assigns = @view.assigns

        if @view.content_for?(:layout)
          assigns["content_for_layout"] = @view.content_for(:layout)
        end
        assigns.merge!(local_assigns.stringify_keys)

        controller = @view.controller
        filters = if controller.respond_to?(:liquid_filters, true)
                    controller.send(:liquid_filters)
                  elsif controller.respond_to?(:master_helper_module)
                    [controller.master_helper_module]
                  else
                    [controller._helpers]
                  end

        liquid = ::Liquid::Template.parse(template)
        render_assigns = assigns.with_indifferent_access
        render_opts = {:filters => filters, :registers => {:action_view => @view, :controller => @view.controller}}
        if self.class.lesmok_options[:rethrow_errors]
          text = liquid.render!(render_assigns, render_opts)
        else
          text = liquid.render(render_assigns, render_opts)
        end
        if ::Lesmok.config.debugging?
          log_any_liquid_errors(liquid.errors)
          log_any_liquid_errors(liquid.warnings, 'warning')
        end

        text.html_safe
      end

      def log_any_liquid_errors(errors, type_str = 'error')
        return if errors.blank?
        log = ::Rails.logger
        log.warn "[Lesmok] Template #{type_str}s (#{errors.size}) detected!"
        errors.each do |err|
          log.debug "  -- Liquid #{type_str}: #{err}"
        end
      end

      def compilable?
        false
      end
    end

  end # Liquid
end # Lesmok
