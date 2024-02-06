# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

require 'code_structure/code_elem'

module CodeStructure
  class CodeElemBuildOption
     attr_accessor :oType, :oValue

    def initialize(oType, oValue)
      @element_id = CodeStructure::CodeElemTypes::ELEM_BUILD_OPTION;

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
