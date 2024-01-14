##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information for the parent code structure
# read in from an xml file

require 'code_elem'
require 'code_elem_include'
require 'code_elem_use'
require 'code_elem_namespace'
require 'filters/data_filter'

module CodeStructure
  class CodeElemClassSpec < CodeElem
    attr_accessor :functions, :namespace, :plugName, :interfaceNamespace, :interfacePath,
                  :testNamespace, :testPath, :templateParams,
                  :includes, :uses, :baseClasses, :interfaces, :language, :path, :varPrefix, :model,
                  :filePath, :name, :standardClass, :standardClassType, :customCode, :preDefs, :className,
                  :genCfg, :injections, :dataClass, :featureGroup, :variant, :class_group_ref, :actions, :data_class_for

    def initialize(parentElem, model, pComp, _isStatic)
      super(parentElem)

      @elementId = CodeElem::ELEM_CLASS_GEN
      @name = nil
      @className = nil # Override name for generated class

      @language = nil
      @includes = []
      @uses = []
      @functions = []
      @baseClasses = []
      @interfaces = []
      @injections = []
      @namespace = CodeElemNamespace.new
      @interfaceNamespace = CodeElemNamespace.new
      @testNamespace = CodeElemNamespace.new
      @templateParams = []
      @varPrefix = ''
      @preDefs = []
      @actions = []
      @path = ''
      @model = model
      @genCfg = pComp

      # Used by per lang instance of class
      @name = nil
      @filePath = nil
      @standardClass = nil
      @standardClassType = nil
      @customCode = nil
      @dataClass = nil
      @class_group_ref = nil
      @cgName = nil
      @variant = nil
      @featureGroup = nil
    end

    def addInclude(iPath, iName, iType = nil)
      iPath = String.new if iPath.nil?

      raise 'Include name cannot be nil' if iName.nil? || iName.length == 0

      curInc = nil

      for i in @includes
        curInc = i if i.path == iPath && i.name == iName
      end

      return unless curInc.nil?

      curInc = CodeElemInclude.new(iPath, iName, iType)
      @includes << curInc
    end

    def addUse(use, _forClass = nil)
      curUse = nil
      usNs = CodeElemNamespace.new(use)

      for i in @uses
        curUse = i if i.namespace.same?(usNs)
      end

      return unless curUse.nil?

      curUse = CodeElemUse.new(usNs)
      @uses << curUse
    end

    def addInjection(var)
      found = false
      for inj in @injections
        return true if inj.name == var.name && inj.getUType == var.getUType
      end

      @injections << var
    end

    def hasUsing(useName)
      for i in @uses
        return true if i.namespace == useName
      end

      return false
    end

    def getUName
      return @className if !@className.nil?

      return @model.name
    end

    def setName(newName)
      @name = newName
    end

    def findVar(varName, varNs = nil)
      varFound = findVarInGroup(@model.varGroup, varName, varNs)
      return varFound if !varFound.nil?

      return nil
    end

    def findVarInGroup(vGroup, varName, varNs)
      for var in vGroup.vars
        return var if var.name == varName && (varNs.nil? || var.namespace.get('.') == varNs)
      end

      for grp in vGroup.varGroups
        varFound = findVarInGroup(grp, varName, varNs)
        return varFound if !varFound.nil?
      end

      return nil
    end
  end
end
