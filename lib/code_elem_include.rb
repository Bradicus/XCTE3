##

# 
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class stores information for the include code structure
# read in from an xml file
 
require 'code_structure/code_elem'

class CodeElemInclude < CodeStructure::CodeElem
  attr_accessor :itype, :path
  
  def initialize(path, name = nil, itype = '"')
    super(CodeStructure::CodeElemTypes::ELEM_INCLUDE, nil)

    if name != nil
      @name = name
    else
      @name = String.new
    end
	
	  if (itype != nil)
	    @itype = itype
    end

    if !path.nil?
      @path = path
    end
  end
end
