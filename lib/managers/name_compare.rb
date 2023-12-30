##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

class NameCompare
  def self.matches(n1, n2)
    if !n1.nil? && !n2.nil?
      return n1.tr(' ', '').downcase == n2.tr(' ', '').downcase
    end

    return true
  end
end
