##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class stores information for the format code structure
# read in from an xml file

class CodeElemFormat < CodeElem
  attr_accessor :formatText
  
  def initialize(formatText)
    @elementId = CodeElem::ELEM_FORMAT
    
    @formatText = formatText
  end
end
