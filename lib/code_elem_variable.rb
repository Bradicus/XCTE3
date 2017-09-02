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
  attr_accessor :vtype, :utype,:templateType, :defaultValue, :comment,
    :visibility, :isConst, :isStatic, :isPointer, :isVirtual, :passBy, :genSet, :genGet,
    :arrayElemCount, :listType, :nullable, :identity, :isPrimary

  def initialize(parentElem)
    super(parentElem)
    
    @elementId = CodeElem::ELEM_VARIABLE
    
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
    @identity = nil
    @isPrimary = false
    @listType = nil

    # Stored only for arrays
    @arrayElemCount = 0 	# Array size of 0 means this isn't an array

   # puts "[CodeElemVariable::initialize] Creating variable"
  end

  # Returns parameter version of this variable, that can be used in function calls to pass data that
  # can later be assigned to this variable.
  def getParam()
    param = CodeElemVariable.new(@parentElem)
    param.name = @name
    param.vtype = @vtype
    param.utype = @utype
    param.templateType = @templateType
    param.listType = @listType
    param.arrayElemCount = @arrayElemCount

    return param
  end

end
