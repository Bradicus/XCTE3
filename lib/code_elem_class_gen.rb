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
require 'code_elem_include.rb'

class CodeElemClassGen < CodeElem
  attr_accessor :functions, :namespaceList, :ctype, :interfaceNamespace, :interfacePath,
                :testNamespace, :testPath
                :name, :includes, :baseClasses, :language, :path, :varPrefix

  def initialize(parentElem)
    super(parentElem)

    @elementId = CodeElem::ELEM_CLASS_GEN
    @name = nil

    @language = nil
    @includes = Array.new
    @functions = Array.new
    @baseClasses = Array.new
    @namespaceList = Array.new
    @varPrefix = ''
    @path = nil
  end

  def addInclude(iPath, iName, iType = nil)
    if iPath.nil?
      iPath = String.new
    end

    if (iName.nil? || iName.length == 0)
      raise "Include name cannot be nil";
    end

    curInc = nil

    for i in @includes
      if i.path == iPath && i.name == iName
        curInc = i
      end
    end

    if curInc == nil
      curInc = CodeElemInclude.new(iPath, iName, iType)
      @includes << curInc
    end
  end
end
