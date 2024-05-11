#
# Copyright (C) 2017 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions useful for all languages.

require "lang_profile"
require "params/process_dependencies_params"
require "code_structure/code_elem_spec_and_plugin"
require "log"

class UtilsBase
  attr_accessor :langProfile

  def initialize(langName)
    @langProfile = LangProfiles.instance.profiles[langName]

    return unless @langProfile.nil?

    Log.debug("Profile " + langName + " not found")
  end

  # Returns true if this is a primitive data type
  def is_primitive(var)
    @langProfile.is_primitive(var)
  end

  def is_numeric?(var)
    isPrim = @langProfile.is_primitive(var)
    isNum = Types.instance.inCategory(var, "number")
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
  def get_styled_variable_name(var, prefix = "", postfix = "")
    CodeNameStyling.getStyled(prefix + var.name + postfix, @langProfile.variableNameStyle)
  end

  def style_as_variable(var_string)
    CodeNameStyling.getStyled(var_string, @langProfile.variableNameStyle)
  end

  def style_as_function(fun_string)
    CodeNameStyling.getStyled(fun_string, @langProfile.functionNameStyle)
  end

  # Returns the version of this class name styled for this language
  def style_as_class(className)
    CodeNameStyling.getStyled(className, @langProfile.classNameStyle)
  end

  # Returns the version of this class name styled for this language
  def style_as_namespace(nsName)
    CodeNameStyling.getStyled(nsName, @langProfile.classNameStyle)
  end

  def style_as_enum(enumName)
    CodeNameStyling.getStyled(enumName, @langProfile.enumNameStyle)
  end

  # Returns the version of this file name styled for this language
  def style_as_file_name(fileName)
    CodeNameStyling.getStyled(fileName, @langProfile.fileNameStyle)
  end

  # Returns the version of this file name styled for this language
  def style_as_path_name(pathName)
    CodeNameStyling.getStyled(pathName, @langProfile.directoryNameStyle)
  end

  # Get the extension for a file type
  def get_extension(eType)
    @langProfile.get_extension(eType)
  end

  # Create a variable with a type cls
  def create_var_for(cls, plug_name, visibility = nil)
    plugClass = cls.model.findClassModel(plug_name)
    plug = XCTEPlugin.findClassPlugin(@langProfile.name, plug_name)

    if plugClass.nil?
      Log.debug("Class not found for " + plug_name)
      return nil
    end
    if plug.nil?
      Log.debug("Plugin not found for " + plug_name)
      return nil
    end

    newVar = CodeStructure::CodeElemVariable.new(nil)
    newVar.utype = plug.get_unformatted_class_name(plugClass)
    newVar.name = newVar.utype

    if visibility != nil
      newVar.visibility = visibility
    end

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
        bld.same_line(get_comment(var))
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
        bld.add(Utils.instance.get_comment(funItem))
      elsif funItem.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
        if funItem.formatText == "\n"
          bld.add
        else
          bld.same_line(funItem.formatText)
        end
      elsif funItem.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
        bld.add(get_comment(funItem))
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
    bc_cls_spec = ClassModelManager.findClass(cls_ref.model_name, cls_ref.plugin_name)

    if !bc_cls_spec.nil?
      try_add_include_for(to_cls, bc_cls_spec, cls_ref.plugin_name)
    else
      Log.warn "Could not find class for class ref " + bc.model_name.to_s + " " + bc.plugin_name.to_s
    end
  end

  # Add an include if there's a class model defined for it
  def try_add_include_for(to_cls, for_cls, plug_name)
    clsPlug = XCTEPlugin.findClassPlugin(@langProfile.name, plug_name)

    if !clsPlug.nil? && !for_cls.nil?
      for_cls_spec = for_cls.model.findClassModel(plug_name)

      if !for_cls_spec.nil?
        to_cls.addInclude(clsPlug.get_file_path(for_cls_spec), clsPlug.get_file_name(for_cls_spec))
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

    cls.addInclude(clsPlug.get_dependency_path_w_file(clsGen), clsPlug.get_class_name(clsGen))
  end

  def is_self_reference(cls, var, clsPlug)
    varUType = var.getUType
    classUType = clsPlug.get_unformatted_class_name(cls)
    varUType == classUType
  end

  def get_plugin_and_spec_for_ref(cls_spec, cls_ref)
    pas = CodeStructure::CodeElemSpecAndPlugin.new

    pas.spec = ClassModelManager.findClass(cls_ref.model_name, cls_ref.plugin_name)
    pas.plugin = XCTEPlugin::findClassPlugin(cls_spec.language, cls_ref.plugin_name)

    if pas.spec.nil?
      Log.info "Unable to find class spec for model: " + cls_ref.model_name + " " + cls_ref.plugin_name
    end

    if pas.plugin.nil?
      Log.info "Unable to find class plugin for model: " + cls_ref.model_name + " " + cls_ref.plugin_name
    end

    return pas
  end

  def render_param_list(pList)
    oneLiner = pList.join(", ")
    return unless pList.length > 100

    pList.join(", ")
  end

  def has_an_array?(cls)
    each_var(UtilsEachVarParams.new.wCls(cls).wSeparate(true).wVarCb(lambda { |var|
      true if var.arrayElemCount > 0
    }))

    false
  end
end
