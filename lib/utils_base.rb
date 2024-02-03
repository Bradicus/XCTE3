#
# Copyright (C) 2017 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions useful for all languages.

require 'lang_profile'
require 'params/process_dependencies_params'
require 'log'

class UtilsBase
  attr_accessor :langProfile

  def initialize(langName)
    @langProfile = LangProfiles.instance.profiles[langName]

    return unless @langProfile.nil?

    Log.debug('Profile ' + langName + ' not found')
  end

  # Returns true if this is a primitive data type
  def is_primitive(var)
    @langProfile.is_primitive(var)
  end

  def is_numeric?(var)
    isPrim = @langProfile.is_primitive(var)
    isNum = Types.instance.inCategory(var, 'number')
    isPrim && isNum
  end

  # Return the language type based on the generic type
  def get_type_name(var)
    return @langProfile.get_type_name(var.vtype) if !var.vtype.nil?

    CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle)
  end

  # Return the language type based on the generic type
  def get_type(gType)
    @langProfile.get_type(gType)
  end

  # Returns the version of this name styled for this language
  def get_styled_variable_name(var, prefix = '', postfix = '')
    CodeNameStyling.getStyled(prefix + var.name + postfix, @langProfile.variableNameStyle)
  end

  def get_styled_function_name(funName)
    CodeNameStyling.getStyled(funName, @langProfile.functionNameStyle)
  end

  # Returns the version of this class name styled for this language
  def get_styled_class_name(className)
    CodeNameStyling.getStyled(className, @langProfile.classNameStyle)
  end

  # Returns the version of this class name styled for this language
  def get_styled_namespace_name(nsName)
    CodeNameStyling.getStyled(nsName, @langProfile.classNameStyle)
  end

  def get_styled_enum_name(enumName)
    CodeNameStyling.getStyled(enumName, @langProfile.enumNameStyle)
  end

  # Returns the version of this file name styled for this language
  def get_styled_file_name(fileName)
    CodeNameStyling.getStyled(fileName, @langProfile.fileNameStyle)
  end

  # Returns the version of this file name styled for this language
  def get_styled_path_name(pathName)
    CodeNameStyling.getStyled(pathName, @langProfile.directoryNameStyle)
  end

  # Get the extension for a file type
  def get_extension(eType)
    @langProfile.get_extension(eType)
  end

  # Create a variable with a type cls
  def create_var_for(cls, plug_name)
    plugClass = cls.model.findClassModel(plug_name)
    plug = XCTEPlugin.findClassPlugin(@langProfile.name, plug_name)

    if plugClass.nil?
      Log.debug('Class not found for ' + plug_name)
      return nil
    end
    if plug.nil?
      Log.debug('Plugin not found for ' + plug_name)
      return nil
    end

    newVar = CodeStructure::CodeElemVariable.new(nil)
    newVar.utype = plug.get_unformatted_class_name(plugClass)
    newVar.name = newVar.utype

    newVar
  end

  # Run a function on each variable in a class
  def each_var(params)
    each_var_grp(params.cls.model.varGroup, params.bld, params.separateGroups, params.varCb, params.bgCb, params.agCb)
  end

  # Run a function on each variable in a variable group and subgroups
  def each_var_grp(vGroup, bld, separateGroups, varFun, bgCb, agCb)
    for var in vGroup.vars
      if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
        varFun.call(var)
      elsif !bld.nil? && var.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
        bld.same_line(getComment(var))
      elsif !bld.nil? && var.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
        bld.add(var.formatText)
      end
    end

    for grp in vGroup.varGroups
      bgCb.call(grp) if !bgCb.nil?
      each_var_grp(grp, bld, separateGroups, varFun, bgCb, agCb)
      agCb.call(grp) if !agCb.nil?
      bld.separate if separateGroups && !bld.nil?
    end
  end

  # Run a function on each function in a class
  def each_fun(params)
    for clsFun in params.cls.functions
      if clsFun.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION
        params.bld.separate

        params.funCb.call(clsFun) if clsFun.isTemplate
      elsif funItem.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
        bld.add(Utils.instance.getComment(funItem))
      elsif funItem.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
        if funItem.formatText == "\n"
          bld.add
        else
          bld.same_line(funItem.formatText)
        end
      elsif funItem.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
        bld.add(getComment(funItem))
      elsif funItem.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
        if funItem.formatText == "\n"
          bld.add
        else
          bld.same_line(funItem.formatText)
        end
      end
    end
  end

  # Add an include if there's a class model defined for it
  def try_add_include_for_class_ref(to_cls, cls_ref)
    bc_cls_spec = ClassModelManager.findClass(bc.model_name, bc.plugin_name)

    if !bc_cls_spec.nil?
      get_default_utils().try_add_include_for(to_cls, bc_cls_spec, bc.plugin_name)
    else
      Log.warn 'Could not find class for class ref ' + bc.model_name.to_s + " " + bc.plugin_name.to_s
    end
  end

  # Add an include if there's a class model defined for it
  def try_add_include_for(to_cls, for_cls, plug_name)
    clsPlug = XCTEPlugin.findClassPlugin(@langProfile.name, plug_name)

    if !clsPlug.nil?
      for_cls_spec = for_cls.model.findClassModel(plug_name)

      if !for_cls_spec.nil?
        to_cls.addInclude(clsPlug.get_dependency_path(for_cls_spec), clsPlug.get_class_name(for_cls_spec))
      end
    else
      Log.warn "[try_add_include_for] Couldn't find class plugin: " + plug_name.to_s
    end
  end

  # Add an include if there's a class model defined for it
  def try_add_include_for_var(cls, var, plug_name)
    clsPlug = XCTEPlugin.findClassPlugin(@langProfile.name, plug_name)
    clsGen = ClassModelManager.findClass(var.getUType, plug_name)

    return unless !clsPlug.nil? && !clsGen.nil? && !is_self_reference(cls, var, clsPlug)

    cls.addInclude(clsPlug.get_dependency_path(clsGen), clsPlug.get_class_name(clsGen))
  end

  def is_self_reference(cls, var, clsPlug)
    varUType = var.getUType
    classUType = clsPlug.get_unformatted_class_name(cls)
    varUType == classUType
  end

  def render_param_list(pList)
    oneLiner = pList.join(', ')
    return unless pList.length > 100

    pList.join(', ')
  end

  def has_an_array?(cls)
    each_var(UtilsEachVarParams.new.wCls(cls).wSeparate(true).wVarCb(lambda { |var|
      true if var.arrayElemCount > 0
    }))

    false
  end
end
