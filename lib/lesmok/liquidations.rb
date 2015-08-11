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
  def to_liquid
    hash = Hash.new
    self.members.each do |k|
      hash[k.to_s] = self[k]
    end
    hash
  end
end
