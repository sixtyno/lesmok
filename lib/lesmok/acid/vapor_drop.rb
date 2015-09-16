require 'lesmok/acid/drop'

module Lesmok
  module Acid

      ##
      # Deferred fetching of liquid drop.
      #
      # [VaporDrop] => [Drop] => [(parent) source object]
      #
      # Usage:
      #
      #   ::Lesmok::Acid::VaporDrop.new(id: 123, title: 'Amigos') do |data|
      #      MyMovieLibrary.find_by_id(data[:id])
      #   end
      #
      class VaporDrop < Drop

        def initialize(data, options = {}, &block)
          super(nil,options)
          @source_fetcher = block
          @source_data    = data
        end

        ##
        # Find the actual object and drop that should handle this.
        #
        def condense_acid_drop!
          @parent_source_object ||= begin
            (@source_fetcher && @source_fetcher.call(@source_data))
          end
          # Note that the source of _this_ drop, is the drop it wraps.
          @source_object ||= @parent_source_object && @parent_source_object.to_liquid
        end

        def condensed_acid_drop?
          @parent_source_object || @source_object
        end


        ##
        # Try to avoid subsequent access from needing to go through
        # the VaporDrop after the source object has been fetched.
        #
        def to_liquid
          if condensed_acid_drop?
            @source_object.to_liquid # The source liquid drop.
          else
            self
          end
        end

        ##
        # Delegate to the source liquid drop only if we
        # have already fetched it _or_ we don't have the
        # in the pre-fetch data hash
        #
        def before_method(method_name)
          return super if condensed_acid_drop?
          if @source_data.key?(method_name)
            @source_data[method_name]
          else
            condense_acid_drop!
            super
          end
        end

      end


  end
end
