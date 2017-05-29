##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class stores information for the function code structure
# read in from an xml file

class CodeElemFunction < CodeElem
  attr_accessor :name, :description, :visibility, :parameters, :isConst, :isStatic, :isVirtual, :isInline, :isTemplate, :returnValue
  
  def initialize
    @elementId = CodeElem::ELEM_FUNCTION
    
    @name
    @description
	
    @visibility
    @parameters = Array.new # Array of CodeElemVariable
    @isConst = false
    @isStatic = false
    @isVirtual = false
    @isInline = false
    @isTemplate = false
    @returnValue = CodeElemVariable.new
    @returnValue.vtype = "void"
  end
end
