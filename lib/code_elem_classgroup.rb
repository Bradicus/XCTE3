##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores a class group

module CodeStructure
  class CodeElemClassgroup < CodeElem
    attr_accessor :featureGroup

    @featureGroup = nil

    def initialize(parentElem)
      super(parentElem)
    end
  end
end
