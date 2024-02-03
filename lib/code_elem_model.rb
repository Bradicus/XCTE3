##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information for the class code structure
# read in from an xml file

require 'code_structure/code_elem'
require 'code_structure/code_elem_class_spec'

require 'code_elem_comment'
require 'code_elem_format'
require 'code_elem_function'
require 'code_elem_include'
require 'code_elem_parent'
require 'code_elem_variable'
require 'code_elem_var_group'
require 'rexml/document'
require 'filters/data_filter'

module CodeStructure
  class CodeElemModel < CodeStructure::CodeElem
    attr_accessor :classes, :name, :description,
                  :case, :varGroup, :xmlFileName, :lastModified,
                  :modelSet, :feature_group, :data_filter

    def initialize
      super(CodeStructure::CodeElemTypes::ELEM_MODEL, nil)
      
      @classes = []
      @varGroup = CodeElemVarGroup.new
      @xmlFileName = ''
      @modelSet = nil
      @feature_group = nil
      @data_filter = Filters::DataFilter.new
    end

    def copy
      ret = clone
      ret.classes = @classes.map(&:clone)
    end

    def add_var(var)
      varGroup.vars << var
    end

    #
    # Finds a class that this model has by type name
    #
    def findClassSpecByPluginName(plug_name)
      for cls in @classes
        return cls if cls.plug_name == plug_name
      end

      return nil
    end

    # Returns whether or not this class has an variable of this type
    def hasVariableType(vt)
      return hasVariableTypeinGroup(@varGroup, vt)
    end

    # Returns whether or not this class has an variable of this type
    def hasVariableTypeinGroup(vGroup, vt)
      for var in vGroup.vars
        return true if var.getUType.downcase == vt.downcase
      end

      for grp in vGroup.varGroups
        return true if hasVariableTypeinGroup(grp, vt)
      end

      return false
    end

    def getObjFileName
      lowName = @name
      lowName = lowName.downcase

      return(lowName + '.o') if !@case.nil? && !lowName.nil?

      return(@name + '.o')
    end

    def getCppFileName
      lowName = @name
      lowName = lowName.downcase

      return(lowName + '.cpp') if !@case.nil? && !lowName.nil?

      return(@name + '.cpp')
    end

    def getHeaderFileName
      lowName = @name
      lowName = lowName.downcase

      return(lowName + '.h') if !@case.nil? && !lowName.nil?

      return(@name + '.h')
    end

    def get_var_by_name(var_name)
      vars = getFilteredVars(->(var) { var.name == var_name })

      if !vars.empty?
        return vars[0]
      end

      return null
    end

    def getFilteredVars(filterFun)
      varArray = []
      getFilteredGroup(@varGroup, varArray, filterFun)

      return varArray
    end

    def getScreenVars(varArray, filterFun)
      getFilteredGroup(@varGroup, varArray, filterFun)
    end

    # Screen variables based on pass functoin
    def getFilteredGroup(vGroup, varArray, filterFun)
      for var in vGroup.vars
        varArray << var if filterFun.call(var)
      end

      for grp in vGroup.varGroups
        getFilteredGroup(grp, varArray, filterFun)
      end
    end

    # Returns add primary keys from vGroup
    def getPrimaryKeyVars(varArray)
      getScreenVars(varArray, ->(var) { var.isPrimary == true })
    end

    # Returns add primary keys from vGroup
    def getNonIdentityVars(varArray)
      getScreenVars(varArray, ->(var) { var.identity.nil? })
    end

    # Returns add primary keys from vGroup
    def getIdentityVar
      varArray = []
      getScreenVars(varArray, ->(var) { !var.identity.nil? })

      return(varArray[0]) if varArray.length > 0

      return nil
    end

    # Find class
    def findClassModel(classplug_name)
      for c in @classes
        return c if c.plug_name == classplug_name
      end

      return nil
    end
  end
end
