##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores a class group

require 'code_structure/code_elem'

module CodeStructure
  class CodeElemClassgroup < CodeStructure::CodeElem
    attr_accessor :featureGroup, :cFor

    @featureGroup = nil
    @cFor = nil

    def initialize(parentElem)
      super(nil, parentElem)
    end
  end
end
