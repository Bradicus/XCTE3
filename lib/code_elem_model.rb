##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information for the class code structure
# read in from an xml file

require "code_elem.rb"
require "code_elem_class_gen.rb"
require "code_elem_comment.rb"
require "code_elem_format.rb"
require "code_elem_function.rb"
require "code_elem_include.rb"
require "code_elem_parent.rb"
require "code_elem_variable.rb"
require "code_elem_var_group.rb"
require "rexml/document"

module CodeStructure
  class CodeElemModel < CodeElem
    attr_accessor :classes, :name, :description,
                  :case, :groups, :xmlFileName, :lastModified

    def initialize
      super()

      @elementId = CodeElem::ELEM_MODEL
      @name
      @case
      @description
      @classes = Array.new
      @groups = Array.new
      @xmlFileName = ""
      @lastModified
    end

    #
    # Finds a class that this model has by type name
    #
    def findClassByType(classType)
      for cls in @classes
        if cls.ctype == classType
          return cls
        end
      end

      return nil
    end

    # Returns whether or not this class has an array variable
    def hasAnArray
      varArray = Array.new

      for vGrp in groups
        CodeElemModel.getVarsFor(vGrp, varArray)
      end

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE && var.arrayElemCount.to_i > 0
          return true
        end
      end

      return false
    end

    # Returns whether or not this class has an variable of this type
    def hasVariableType(vt)
      variableSection = Array.new
      getAllVarsFor(nil, variableSection)
      for var in variableSection
        if var.elementId == CodeElem::ELEM_VARIABLE && var.vtype == vt
          return true
        end
      end

      return false
    end

    def getObjFileName
      lowName = @name
      lowName = lowName.downcase

      if (@case != nil && lowName != nil)
        return(lowName + ".o")
      else
        return(@name + ".o")
      end
    end

    def getCppFileName
      lowName = @name
      lowName = lowName.downcase

      if (@case != nil && lowName != nil)
        return(lowName + ".cpp")
      else
        return(@name + ".cpp")
      end
    end

    def getHeaderFileName
      lowName = @name
      lowName = lowName.downcase

      if (@case != nil && lowName != nil)
        return(lowName + ".h")
      else
        return(@name + ".h")
      end
    end

    # Returns all variables in this class that match the cfg
    def self.getVarsFor(vGroup, vArray)
      for var in vGroup.vars
        vArray << var
      end

      for grp in vGroup.groups
        getVarsFor(grp, vArray)
      end

      # puts vArray.size
    end

    # Returns all variables in this class that match the cfg
    def getAllVarsFor(varArray)
      for vGroup in @groups
        CodeElemModel.getVarsFor(vGroup, varArray)
      end
    end

    def getScreenVars(varArray, screenFunction)
      for vGroup in @groups
        getScreenGroup(vGroup, varArray, screenFunction)
      end
    end

    # Screen variables based on pass functoin
    def getScreenGroup(vGroup, varArray, screenFunction)
      for var in vGroup.vars
        if screenFunction.call(var)
          varArray << var
        end
      end

      for grp in vGroup.groups
        getScreenGroup(grp, varArray, screenFunction)
      end
    end

    # Returns add primary keys from vGroup
    def getPrimaryKeyVars(varArray)
      getScreenVars(varArray, lambda { |var| var.isPrimary == true })
    end

    # Returns add primary keys from vGroup
    def getNonIdentityVars(varArray)
      getScreenVars(varArray, lambda { |var| var.identity == nil })
    end

    # Returns add primary keys from vGroup
    def getIdentityVar()
      varArray = Array.new
      getScreenVars(varArray, lambda { |var| var.identity != nil })

      if (varArray.length > 0)
        return(varArray[0])
      end

      return nil
    end

    # Returns namespaces separated by .
    def getNamespaceList(cfg, varArray)
      if @namespaceList != nil
        return @namespaceList.join(".")
      else
        return ""
      end
    end

    # Find class
    def findClass(classPlugName)
      for c in @classes
        if (c.ctype == classPlugName)
          return c
        end
      end

      return nil
    end
  end
end
