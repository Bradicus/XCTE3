##

# 
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class stores information for the format code structure
# read in from an xml file

require 'code_structure/code_elem'

class CodeElemFormat < CodeStructure::CodeElem
  attr_accessor :formatText
  
  def initialize(formatText)
    @element_id = CodeStructure::CodeElemTypes::ELEM_FORMAT
    
    @formatText = formatText
  end
end
