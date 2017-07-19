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

class CodeElemClassGen < CodeElem
  attr_accessor :functions, :namespaceList, :ctype, :interfaceNamespace, :name, :includes, :baseClasses

  def initialize(parentElem)
    super(parentElem)

    @elementId = CodeElem::ELEM_CLASS_GEN
    @name = nil

    @includes = Array.new
    @functions = Array.new
    @baseClasses = Array.new
    @namespaceList = Array.new
  end
end
