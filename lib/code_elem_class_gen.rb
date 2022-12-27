##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information for the parent code structure
# read in from an xml file

require "code_elem.rb"
require "code_elem_include.rb"
require "code_elem_use.rb"
require "code_elem_namespace.rb"

module CodeStructure
  class CodeElemClassGen < CodeElem
    attr_accessor :functions, :namespace, :ctype, :interfaceNamespace, :interfacePath,
                  :testNamespace, :testPath, :templateParams,
                  :includes, :uses, :baseClasses, :interfaces, :language, :path, :varPrefix, :model,
                  :dontModifyCode,
                  :filePath, :name, :standardClass, :standardClassType, :customCode, :preDefs, :className, :genCfg, :injections
    attr_reader :name

    def initialize(parentElem, model, isStatic)
      super(parentElem)

      @elementId = CodeElem::ELEM_CLASS_GEN
      @name = nil
      @className = nil # Override name for generated class

      @language = nil
      @includes = Array.new
      @uses = Array.new
      @functions = Array.new
      @baseClasses = Array.new
      @interfaces = Array.new
      @injections = Array.new
      @namespace = CodeElemNamespace.new
      @interfaceNamespace = CodeElemNamespace.new
      @testNamespace = CodeElemNamespace.new
      @templateParams = Array.new
      @varPrefix = ""
      @preDefs = Array.new
      @path = nil
      @model = model
      @dontModifyCode = isStatic
      @genCfg

      # Used by per lang instance of class
      @name = nil
      @filePath = nil
      @standardClass = nil
      @standardClassType = nil
      @customCode = nil
    end

    def addInclude(iPath, iName, iType = nil)
      if iPath.nil?
        iPath = String.new
      end

      if (iName.nil? || iName.length == 0)
        raise "Include name cannot be nil"
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

    def addUse(use, forClass = nil)
      curUse = nil
      usNs = CodeElemNamespace.new(use)

      for i in @uses
        if i.namespace.same?(usNs)
          curUse = i
        end
      end

      if curUse == nil
        curUse = CodeElemUse.new(usNs)
        @uses << curUse
      end
    end

    def addInjection(var)
      found = false
      for inj in @injections
        if (inj.name == var.name && inj.getUType() == var.getUType())
          return true
        end
      end

      @injections << var
    end

    def hasUsing(useName)
      for i in @uses
        if i.namespace == useName
          return true
        end
      end

      return false
    end

    def getUName()
      if (@className != nil)
        return @className
      end

      return @model.name
    end

    def setName(newName)
      @name = newName
    end

    def findVar(varName, varNs = nil)
      varFound = findVarInGroup(@model.varGroup, varName, varNs)
      if (varFound != nil)
        return varFound
      end

      return nil
    end

    def findVarInGroup(vgroup, varName, varNs)
      for var in vgroup.vars
        if var.name == varName && (varNs == nil || var.namespace.get(".") == varNs)
          return var
        end
      end

      for grp in vGroup.varGroups
        varFound = findVarInGroup(grp, varName, varNs)
        if (varFound != nil)
          return varFound
        end
      end

      return nil
    end
  end
end
