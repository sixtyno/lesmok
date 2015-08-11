require 'liquid'

# Optional `to_liquid` definitions injected into various classes.
#
# Require this file explicitly to use.

class Symbol
  def to_liquid
    to_s
  end
end

class Struct
  include ::Lesmok::Acid::Meltable  # A bit heavy-handed.
end
