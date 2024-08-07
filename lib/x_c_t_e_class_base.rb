require "x_c_t_e_plugin"
require "path_util"
require "params/fun_plugin_params"
require "managers/class_type_manager"

# Base class for all class plugins
class XCTEClassBase < XCTEPlugin
  def get_class_name(cls)
    dutils.style_as_class(get_unformatted_class_name(cls))
  end

  # Return the default utilities instance for this language
  def dutils
    throw :required_implimentation
  end

  def get_source_renderer
    throw :required_implimentation
  end

  def render_namespace_start(cls, bld)
    throw :required_implimentation
  end

  def render_namespace_end(cls, bld)
    throw :required_implimentation
  end

  def render_dependencies(cls, bld)
    throw :required_implimentation
  end

  def process_dependencies(cls_spec)
    # Add in any dependencies required by functions
    dutils().each_fun(UtilsEachFunParams.new.w_cls(cls_spec).w_fun_cb(lambda { |fun|
      if fun.isTemplate
        templ = PluginManager.find_method_plugin(cls_spec.language, fun.name)
        if !templ.nil?
          Log.info "processing fun: " + fun.name
          templ.process_dependencies(cls_spec, fun)
        else
          Log.warn "ERROR no plugin for function: " + fun.name + "   language: " + cls_spec.language
        end
      end
    }))

    for bc in cls_spec.base_classes
      bc_cls_spec = ClassModelManager.findClass(bc.model_name, bc.plugin_name)

      if !bc_cls_spec.nil?
        dutils().try_add_include_for(cls_spec, bc_cls_spec, bc.plugin_name)
      else
        Log.warn "Could not find class for base class ref " + bc.model_name.to_s + " " + bc.plugin_name.to_s
      end
    end

    #process_var_dependencies(cls_spec)
  end

  def process_var_dependencies(cls_spec)
    # Add in any dependencies required by variables
    dutils.each_var(UtilsEachVarParams.new.wCls(cls_spec).wSeparate(true).wVarCb(lambda { |var|
      pas = nil
      if var.vtype != nil
        pas = ClassTypeManager.find_class_type_by_name(cls_spec.language, var.vtype)
      elsif var.utype != nil
        pas = ClassTypeManager.find_class_type_by_name(cls_spec.language, dutils.get_styled_variable_name(var))
      end

      if pas != nil
        dutils.try_add_include_for(cls_spec, pas.spec, pas.plugin.name)
      end
    }))
  end

  def gen_source_files(cls)
    srcFiles = []

    bld = get_source_renderer()
    bld.lfName = dutils().style_as_file_name(get_unformatted_class_name(cls))
    bld.lfExtension = dutils().get_extension("body")

    process_dependencies(cls)

    render_dependencies(cls, bld)
    render_namespace_start(cls, bld)

    render_file_comment(cls, bld)
    render_body_content(cls, bld)

    render_namespace_end(cls, bld)

    srcFiles << bld

    return srcFiles
  end

  def render_file_comment(cls, bld)
    if ActiveComponent.get().file_comment != nil && ActiveComponent.get().file_comment.length > 0
      bld.comment_file(ActiveComponent.get().file_comment)
    elsif ActiveProject.get().file_comment != nil && ActiveProject.get().file_comment.length > 0
      bld.comment_file(ActiveProject.get().file_comment)
    end
  end

  def get_dependency_path_w_file(cls)
    return get_file_path(cls) + "/" + get_file_name(cls)
  end

  def get_file_name(cls)
    dutils.style_as_file_name(get_unformatted_class_name(cls))
  end

  def get_file_path(cls)
    if !cls.path.nil? && cls.path.length > 0
      depPath = dutils.style_as_path_name(cls.path)
    else
      depPath = dutils.style_as_path_name(cls.namespace.get("/"))
    end

    return depPath
  end

  def is_primitive(var)
    dutils.is_primitive(var)
  end

  def hasList(cls)
    each_var(UtilsEachVarParams.new.wCls(cls).wVarCb(lambda { |var|
      true if var.isList
    }))

    false
  end

  def render_functions(cls, bld)
    dutils.each_fun(UtilsEachFunParams.new.w_cls(cls).w_fun_cb(lambda { |fun|
      fp_params = FunPluginParams.new().w_bld(bld).w_cls(cls).w_cplug(self).w_fun(fun)

      if fun.isTemplate
        templ = PluginManager.find_method_plugin(dutils.langProfile.name, fun.name)
        if !templ.nil?
          templ.render_function(fp_params)
        else
          # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'dutils.langProfile.name
        end
      else # Must be empty function
        templ = PluginManager.find_method_plugin(dutils.langProfile.name, "method_empty")
        if !templ.nil?
          templ.render_function(fp_params)
        else
          # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'dutils.langProfile.name
        end
      end
    }))
  end

  def render_head_comment(_bld, _pComponent)
    utils = dutils

    utils.render_block_comment
  end
end
