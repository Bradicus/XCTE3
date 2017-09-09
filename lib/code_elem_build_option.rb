##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information on the library component of a project

module CodeStructure
  class CodeElemBuildOption
     attr_accessor :oType, :oValue

    def initialize(oType, oValue)
      @elementId = CodeElem::ELEM_BUILD_OPTION;

      if (oType != nil)
        @oType = oType
      else
        @oType = String.new
      end

      if (oValue != nil)
        @oValue = oValue
      else
        @oValue = String.new
      end

    end
    
  end
end
