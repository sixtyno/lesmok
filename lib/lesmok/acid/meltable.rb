require 'weakref'
module Lesmok
  module Acid

      module Helpers
        ##
        # Short-hands for use when switching context
        # between liquid and Ruby code, to ensure
        # you get the drop OR the solid source, w/o any overhead.
        #
        def melt  ; to_liquid ; end # "Melts" the object into a liquid.
        def cast  ; to_solid  ; end # "Casts" (as in metal forging) back into the original object.
        def solid ; to_solid  ; end
      end

      ##
      # Indicate that a model can be liquified.
      #
      module Meltable
        include Helpers

        ## Liquify...
        def to_liquid
          drop = begin
            @weak_liquid_drop && @weak_liquid_drop.weakref_alive? && @weak_liquid_drop.__getobj__
          rescue ::WeakRef::RefError => e
            nil # Catch this due to a minor race condition possibility above.
          end
          unless drop
            drop = liquify_dynamically
            @weak_liquid_drop = WeakRef.new(drop)
          end
          drop
        end

        ## Solidify
        def to_solid
          self
        end

        ##
        # Fallback to trying to find the drop class dynamically
        # or use generic AcidDrop if it can't be found.
        #
        def liquify_dynamically
          klass = liquify_drop_klass || AcidDrop
          klass.new(self)
        end

        ##
        # We expect Drop classes to be in same namespace as the object class.
        #
        def liquify_drop_klass
          str = self.class.name + 'Drop'
          klass = str.split('::').inject(Object) do |mod, class_name|
            mod.const_get(class_name)
          end
          klass
        rescue NameError => err
          msg = "[#{self.class}] Could not find liquid drop class..."
          ::Lesmok.logger.warn(msg) if Lesmok.config.debugging?
          Drop
        end

      end

  end
end
