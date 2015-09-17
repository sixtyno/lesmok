module Lesmok
  module Acid

      ##
      # Base module for creating liquid drops
      # which defaults to allowing maximum access
      # class for liquid drops used with Lesmok.
      #
      module Droppable
        include Helpers

        attr_reader :source_object  # Object we delegate to
        attr_reader :acid_options   # Any customization options.
        def initialize(source, opts = {})
          @source_object = source
          @acid_options = opts
        end

        ## Liquify...
        def to_liquid
          self
        end

        ## Solidify
        def to_solid
          @source_object
        end

        ## We default to sending anything through to the source object.
        def before_method(method_name)
          if allow_delegating_method_to_source?(method_name)
            return @source_object.send(method_name)
          else
            msg = "[#{self.class}] The method `#{method_name}` is not defined on #{@source_object.inspect[0..127]}."
            Lesmok.logger.warn(msg) if Lesmok.config.debugging?
            raise NotImplementedError.new(msg) if Lesmok.config.raise_errors?
          end
        end

        def allow_delegating_method_to_source?(method_name)
          @source_object.respond_to?(method_name) && !(method_name.to_s =~ %r{[\=\\!]+\Z})
        end

        def respond_to_missing?(method_name, include_private = false)
          allow_delegating_method_to_source?(method_name) || super
        end

        ## Ensure before_method fallbacks are used both from liquid and when using drop directly.
        def method_missing(method_name, *args)
          (args && args.size > 0) ? super(method_name, *args) : before_method(method_name)
        end

      end

  end
end
