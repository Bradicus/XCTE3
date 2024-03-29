require 'x_c_t_e_plugin'
require 'params/render_fun_def_params'

# Base class for all class plugins
class XCTEClassBase < XCTEPlugin
  def get_class_name(cls)
    get_default_utils.get_styled_class_name(get_unformatted_class_name(cls))
  end

  def get_default_utils
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

  def process_dependencies(cls_spec, bld)
    # Add in any dependencies required by functions
    get_default_utils().each_fun(UtilsEachFunParams.new(cls_spec, bld, lambda { |fun|
      if fun.isTemplate
        templ = XCTEPlugin.findMethodPlugin(cls_spec.language, fun.name)
        if !templ.nil?
          Log.info "processing fun: " + fun.name
          templ.process_dependencies(cls_spec, bld, fun)
        else
          Log.warn 'ERROR no plugin for function: ' + fun.name + '   language: ' + cls_spec.language
        end
      end
    }))

    for bc in cls_spec.base_classes
      bc_cls_spec = ClassModelManager.findClass(bc.model_name, bc.plugin_name)

      if !bc_cls_spec.nil?
        get_default_utils().try_add_include_for(cls_spec, bc_cls_spec, bc.plugin_name)
      else
        Log.warn 'Could not find class for base class ref ' + bc.model_name.to_s + " " + bc.plugin_name.to_s
      end
    end
  end

  def gen_source_files(cls)
    srcFiles = []

    bld = get_source_renderer()
    bld.lfName = get_default_utils().get_styled_file_name(get_unformatted_class_name(cls))
    bld.lfExtension = get_default_utils().get_extension('body')

    process_dependencies(cls, bld)

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

  def get_dependency_path(cls)
    # get_file_name
    fileName = get_file_name(cls)

    if !cls.path.nil?
      depPath = cls.path + '/' + fileName
    else
      depPath = cls.namespace.get('/') + '/' + fileName
    end

    depPath
  end

  def get_file_name(cls)
    get_default_utils.get_styled_file_name(get_unformatted_class_name(cls))
  end

  def is_primitive(var)
    get_default_utils.is_primitive(var)
  end

  def hasList(cls)
    each_var(UtilsEachVarParams.new.wCls(cls).wVarCb(lambda { |var|
      true if var.isList
    }))

    false
  end

  def render_functions(cls, bld)
    get_default_utils.each_fun(UtilsEachFunParams.new(cls, bld, lambda { |fun|
      if fun.isTemplate
        templ = XCTEPlugin.findMethodPlugin(get_default_utils.langProfile.name, fun.name)
        if !templ.nil?
          templ.render_function(cls, bld, fun)
        else
          # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'get_default_utils.langProfile.name
        end
      else # Must be empty function
        templ = XCTEPlugin.findMethodPlugin(get_default_utils.langProfile.name, 'method_empty')
        if !templ.nil?
          templ.render_function(cls, bld, fun)
        else
          # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'get_default_utils.langProfile.name
        end
      end
    }))
  end

  def render_head_comment(_bld, _pComponent)
    utils = get_default_utils

    utils.render_block_comment
  end
end
