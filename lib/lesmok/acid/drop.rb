require 'lesmok/acid/droppable'

module Lesmok
  module Acid

      ##
      # Base fallback class for creating Liquid drops with Lesmok
      #
      class Drop < ::Liquid::Drop
        include Droppable
      end


  end
end
