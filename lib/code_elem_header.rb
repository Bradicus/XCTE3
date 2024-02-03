##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores data for the header

require 'code_structure/code_elem'

module CodeStructure
  class CodeElemHeader < CodeStructure::CodeElem
     attr_accessor :name, :path, :case

    def initialize
      @element_id = ELEM_HEADER;
      @name = String.new
      @path = String.new
      @case
    end

    def getHeaderFileName
      lowName = @name
      lowName = lowName.downcase

      if (@case != nil && lowName != nil)
        return(lowName + ".h");
      else
        return(@name + ".h");
      end
    end
    
  end
end
