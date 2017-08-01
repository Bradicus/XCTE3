##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class stores information for the variable code structure
# read in from an xml file

class CodeElemVariable < CodeElem
  attr_accessor :elementId, :name, :vtype, :templateType, :defaultValue, :comment,
    :visibility, :isConst, :isStatic, :isPointer, :isVirtual, :passBy, :genSet, :genGet,
    :arrayElemCount, :listType, :nullable

  def initialize(parentElem)
    super(parentElem)
    
    @elementId = CodeElem::ELEM_VARIABLE
    
    @name
    @vtype
    @templateType
    @defaultValue
    @comment
    @isVirtual = false
    @isConst = false
    @isStatic = false
    @isPointer = false
    @passBy = "value"
    @genSet = false
    @genGet = false
    @nullable = false
    @listType

    # Stored only for arrays
    @arrayElemCount = 0 	# Array size of 0 means this isn't an array

   # puts "[CodeElemVariable::initialize] Creating variable"
  end
end
