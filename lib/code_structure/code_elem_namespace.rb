##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

require 'code_structure/code_elem'

module CodeStructure
  class CodeElemNamespace < CodeElem
    attr_accessor: ns_list
    
    def initialize(nsString = "")
      @ns_list = []

      if nsString == nil
        nsString = ""
      end
      @ns_list = nsString.split(".")
    end

    def get(separator)
      return @ns_list.join(separator)
    end

    def hasItems?()
      return @ns_list.length > 0
    end

    # is this namespace the same as another
    def same?(otherNs)
      if (otherNs.ns_list == nil && @ns_list == nil)
        return true
      end

      if (otherNs.ns_list == nil || @ns_list == nil)
        return false
      end

      if (otherNs.ns_list.length != @ns_list.length)
        return false
      end

      (0..@ns_list.length - 1).each do |i|
        if (@ns_list[i] != otherNs.ns_list[i])
          return false
        end
      end

      return true
    end
  end
end

