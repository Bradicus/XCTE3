##

# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class stores information for the comment code structure
# read in from an xml file

class CodeElemComment < CodeElem
  attr_accessor :text
  
  def initialize(text)
    @elementId = CodeElem::ELEM_COMMENT
    @text = text
  end
end
