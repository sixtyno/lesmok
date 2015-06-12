require 'liquid'

module Lesmok
    module Tags

      class ErbInclude < ::Liquid::Include
        include ErrorLogging

        class ErbRenderer
          attr_reader :context
          def initialize(liquid_context, template_name)
            @context = liquid_context
            @template_name = template_name
          end
          def extract_vars
            # Not needed if we use action_view directly?
            ctrl.instance_variables.each do |key|
              val = ctrl.instance_variable_get(key)
              self.instance_variable_set(key, val)
            end if ctrl
          end

          def ctrl
            context.registers[:controller]
          end

          def view
            context.registers[:action_view]
          end

          def call(args = {})
            template_name = context[@template_name]
            default_args = {
              partial: template_name,
              template:  template_name,
              registers: context.registers,
              locals: context.scopes.last.with_indifferent_access, # TODO: Make this work?
              liquid_context: context,
            }
            render_args = default_args.merge(args)
            ctrl.send(:render, render_args)
          end
        end
        def render(context)
          with_exception_logging(context) do
            erb = ErbRenderer.new(context, @template_name)
            erb.call
          end
        end
      end

  end
end
