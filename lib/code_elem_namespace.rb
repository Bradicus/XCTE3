##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores namespace information

module CodeStructure
  class CodeElemNamespace < CodeElem
    attr_accessor :nsList

    def initialize(nsString = "")
      if nsString == nil
        nsString = ""
      end
      @nsList = nsString.split(".")
    end

    def get(separator)
      return @nsList.join(separator)
    end

    def hasItems?()
      return @nsList.length > 0
    end

    # is this namespace the same as another
    def same?(otherNs)
      if (otherNs.nsList == nil && @nsList == nil)
        return true
      end

      if (otherNs.nsList == nil || @nsList == nil)
        return false
      end

      if (otherNs.nsList.length != @nsList.length)
        return false
      end

      (0..@nsList.length - 1).each do |i|
        if (@nsList[i] != otherNs.nsList[i])
          return false
        end
      end

      return true
    end
  end
end
