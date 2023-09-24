#
# Copyright (C) 2017 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions useful for all languages.

require "lang_profile.rb"
require "params/process_dependencies_params"
require "log"

class UtilsBase
  attr_accessor :langProfile

  def initialize(langName)
    @langProfile = LangProfiles.instance.profiles[langName]

    if (@langProfile == nil)
      Log.debug("Profile " + langName + " not found")
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

  # Returns the version of this class name styled for this language
  def getStyledNamespaceName(nsName)
    return CodeNameStyling.getStyled(nsName, @langProfile.classNameStyle)
  end

  def getStyledEnumName(enumName)
    return CodeNameStyling.getStyled(enumName, @langProfile.enumNameStyle)
  end

  # Returns the version of this file name styled for this language
  def getStyledFileName(fileName)
    return CodeNameStyling.getStyled(fileName, @langProfile.fileNameStyle)
  end

  # Returns the version of this file name styled for this language
  def getStyledPathName(pathName)
    return CodeNameStyling.getStyled(pathName, @langProfile.fileNameStyle)
  end

  # Get the extension for a file type
  def getExtension(eType)
    return @langProfile.getExtension(eType)
  end

  # Create a variable with a type cls
  def createVarFor(cls, plugName)
    plugClass = cls.model.findClassModel(plugName)
    plug = XCTEPlugin::findClassPlugin(@langProfile.name, plugName)

    if (plugClass == nil)
      Log.debug("Class not found for " + plugName)
      return nil
    end
    if (plug == nil)
      Log.debug("Plugin not found for " + plugName)
      return nil
    end

    newVar = CodeStructure::CodeElemVariable.new(nil)
    newVar.utype = plug.getUnformattedClassName(plugClass)
    newVar.name = newVar.utype

    return newVar
  end

  # Run a function on each variable in a class
  def eachVar(params)
    eachVarGrp(params.cls.model.varGroup, params.bld, params.separateGroups, params.varCb, params.bgCb, params.agCb)
  end

  # Run a function on each variable in a variable group and subgroups
  def eachVarGrp(vGroup, bld, separateGroups, varFun, bgCb, agCb)
    for var in vGroup.vars
      if var.elementId == CodeElem::ELEM_VARIABLE
        varFun.call(var)
      elsif bld != nil && var.elementId == CodeElem::ELEM_COMMENT
        bld.sameLine(getComment(var))
      elsif bld != nil && var.elementId == CodeElem::ELEM_FORMAT
        bld.add(var.formatText)
      end
    end

    for grp in vGroup.varGroups
      if (bgCb != nil)
        bgCb.call(grp)
      end
      eachVarGrp(grp, bld, separateGroups, varFun, bgCb, agCb)
      if (agCb != nil)
        agCb.call(grp)
      end
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
      elsif funItem.elementId == CodeElem::ELEM_COMMENT
        bld.add(Utils.instance.getComment(funItem))
      elsif funItem.elementId == CodeElem::ELEM_FORMAT
        if (funItem.formatText == "\n")
          bld.add
        else
          bld.sameLine(funItem.formatText)
        end
      elsif funItem.elementId == CodeElem::ELEM_COMMENT
        bld.add(getComment(funItem))
      elsif funItem.elementId == CodeElem::ELEM_FORMAT
        if (funItem.formatText == "\n")
          bld.add
        else
          bld.sameLine(funItem.formatText)
        end
      end
    end
  end

  # Add an include if there's a class model defined for it
  def tryAddIncludeFor(cls, plugName)
    clsPlug = XCTEPlugin::findClassPlugin(@langProfile.name, plugName)
    clsGen = cls.model.findClassModel(plugName)

    if clsPlug != nil && clsGen != nil
      cls.addInclude(clsPlug.getDependencyPath(clsGen), clsPlug.getClassName(cls))
    end
  end

  # Add an include if there's a class model defined for it
  def tryAddIncludeForVar(cls, var, plugName)
    clsPlug = XCTEPlugin::findClassPlugin(@langProfile.name, plugName)
    clsGen = ClassModelManager.findClass(var.getUType(), plugName)

    if clsPlug != nil && clsGen != nil && !isSelfReference(cls, var, clsPlug)
      cls.addInclude(clsPlug.getDependencyPath(clsGen), clsPlug.getClassName(clsGen))
    end
  end

  def isSelfReference(cls, var, clsPlug)
    varUType = var.getUType()
    classUType = clsPlug.getUnformattedClassName(cls)
    return varUType == classUType
  end

  def render_param_list(pList)
    oneLiner = pList.join(", ")
    if pList.length > 100
      return pList.join(", ")
    end
  end

  def hasAnArray(cls)
    eachVar(UtilsEachVarParams.new().wCls(cls).wSeparate(true).wVarCb(lambda { |var|
      if var.arrayElemCount > 0
        return true
      end
    }))

    return false
  end
end
