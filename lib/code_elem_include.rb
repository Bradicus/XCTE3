##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class stores information for the include code structure
# read in from an xml file
 
require 'code_elem.rb'

class CodeElemInclude < CodeElem
  attr_accessor :name, :path, :itype
  
  def initialize(name = nil, path = nil, itype = nil)
    @elementId = CodeElem::ELEM_INCLUDE

    if name != nil
      @name = name
    else
      @name = String.new
    end
    
    if path != nil
      @path = path
    else
      @path = String.new
    end
	
	if (itype != nil)
	  @itype = itype;
	end
  end
end
