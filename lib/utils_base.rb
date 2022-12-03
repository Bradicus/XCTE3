#
# Copyright (C) 2017 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions useful for all languages.

require "lang_profile.rb"

class UtilsBase
  attr_accessor :langProfile

  def initialize(langName)
    @langProfile = LangProfiles.instance.profiles[langName]

    if (@langProfile == nil)
      puts("Profile " + langName + " not found")
    end
  end

  # Returns true if this is a primitive data type
  def isPrimitive(var)
    return @langProfile.isPrimitive(var)
  end

  # Return the language type based on the generic type
  def getTypeName(var)
    if (var.vtype != nil)
      return @langProfile.getTypeName(var.vtype)
    else
      return CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle)
    end
  end

  # Return the language type based on the generic type
  def getType(gType)
    return @langProfile.getType(gType)
  end

  # Returns the version of this name styled for this language
  def getStyledVariableName(var, prefix = "", postfix = "")
    return CodeNameStyling.getStyled(prefix + var.name + postfix, @langProfile.variableNameStyle)
  end

  def getStyledFunctionName(funName)
    return CodeNameStyling.getStyled(funName, @langProfile.functionNameStyle)
  end

  # Returns the version of this class name styled for this language
  def getStyledClassName(className)
    return CodeNameStyling.getStyled(className, @langProfile.classNameStyle)
  end

  def getStyledEnumName(enumName)
    return CodeNameStyling.getStyled(enumName, @langProfile.enumNameStyle)
  end

  # Returns the version of this file name styled for this language
  def getStyledFileName(fileName)
    return CodeNameStyling.getStyled(fileName, @langProfile.fileNameStyle)
  end

  # Get the extension for a file type
  def getExtension(eType)
    return @langProfile.getExtension(eType)
  end

  # Run a function on each variable in a class
  def eachVar(params)
    for vGroup in params.cls.model.groups
      eachVarGrp(vGroup, params.bld, params.separateGroups, params.varCb)
    end
  end

  # Run a function on each variable in a variable group and subgroups
  def eachVarGrp(vGroup, bld, separateGroups, varFun)
    for var in vGroup.vars
      if var.elementId == CodeElem::ELEM_VARIABLE
        varFun.call(var)
      elsif bld != nil && var.elementId == CodeElem::ELEM_COMMENT
        bld.sameLine(getComment(var))
      elsif bld != nil && var.elementId == CodeElem::ELEM_FORMAT
        bld.add(var.formatText)
      end
    end

    for grp in vGroup.groups
      eachVarGrp(grp, bld, separateGroups, varFun)
      if (separateGroups && bld != nil)
        bld.separate
      end
    end
  end

  # Run a function on each function in a class
  def eachFun(params)
    for clsFun in params.cls.functions
      if clsFun.elementId == CodeElem::ELEM_FUNCTION
        params.bld.separate

        if clsFun.isTemplate
          params.funCb.call(clsFun)
        end
      end
    end
  end

  # Render functions
  def render_functions(cls, cfg, bld)
    eachFun(UtilsEachFunParams.new(cls, bld, lambda { |fun|
      if fun.isTemplate
        templ = XCTEPlugin::findMethodPlugin(@langProfile.name, fun.name)
        if templ != nil
          templ.get_definition(cls, cfg, bld)
        else
          #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      else # Must be empty function
        templ = XCTEPlugin::findMethodPlugin(@langProfile.name, "method_empty")
        if templ != nil
          templ.get_definition(fun, cfg)
        else
          #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      end
    }))
  end
end
