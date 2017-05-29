##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class stores information for the parent code structure
# read in from an xml file

require 'code_elem.rb'
 
class CodeElemParent < CodeElem
  attr_accessor :name, :visibility
  
  def initialize(name, visibility)
    @elementId = CodeElem::ELEM_PARENT

    if name != nil
      @name = name
    else
      @name = "ERROR no parent name!!!"
    end
    
    if visibility != nil
      @visibility = visibility   
    else
      @visibility = "private"
    end
  end
end
