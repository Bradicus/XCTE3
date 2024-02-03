##

# 
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class stores information for the comment code structure
# read in from an xml file
require 'code_structure/code_elem'

class CodeElemComment < CodeStructure::CodeElem
  attr_accessor :text
  
  def initialize(text)
    @element_id = CodeStructure::CodeElemTypes::ELEM_COMMENT
    @text = text
  end
end
