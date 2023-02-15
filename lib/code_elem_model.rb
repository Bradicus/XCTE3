##

#
# Copyright XCTE Contributors
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
                  :case, :varGroup, :xmlFileName, :lastModified, :derivedFrom, :derivedFor

    def initialize
      super()

      @elementId = CodeElem::ELEM_MODEL
      @name
      @case
      @description
      @classes = Array.new
      @varGroup = CodeElemVarGroup.new
      @derivedFrom = nil
      @derivedFor = nil
      @xmlFileName = ""
      @lastModified
    end

    #
    # Finds a class that this model has by type name
    #
    def findClassByType(classType)
      for cls in @classes
        if cls.plugName == classType
          return cls
        end
      end

      return nil
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

    def getFilteredVars(filterFun)
      varArray = Array.new
      getFilteredGroup(@varGroup, varArray, filterFun)

      return varArray
    end

    def getScreenVars(varArray, filterFun)
      getFilteredGroup(@varGroup, varArray, filterFun)
    end

    # Screen variables based on pass functoin
    def getFilteredGroup(vGroup, varArray, filterFun)
      for var in vGroup.vars
        if filterFun.call(var)
          varArray << var
        end
      end

      for grp in vGroup.varGroups
        getFilteredGroup(grp, varArray, filterFun)
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

    # Find class
    def findClassModel(classPlugName)
      for c in @classes
        if (c.plugName == classPlugName)
          return c
        end
      end

      return nil
    end
  end
end
