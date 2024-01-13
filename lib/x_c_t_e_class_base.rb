require 'x_c_t_e_plugin'
require 'params/render_fun_def_params'

# Base class for all class plugins
class XCTEClassBase < XCTEPlugin
  def getClassName(cls)
    get_default_utils.get_styled_class_name(get_unformatted_class_name(cls))
  end

  def get_default_utils
    throw :required_implimentation
  end

  def getDependencyPath(cls)
    # getFileName
    fileName = getFileName(cls)

    if !cls.path.nil?
      depPath = cls.path + '/' + fileName
    else
      depPath = cls.namespace.get('/') + '/' + fileName
    end

    depPath
  end

  def getFileName(cls)
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
          templ.get_definition(cls, bld, fun)
        else
          # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      else # Must be empty function
        templ = XCTEPlugin.findMethodPlugin(get_default_utils.langProfile.name, 'method_empty')
        if !templ.nil?
          templ.get_definition(cls, bld, fun)
        else
          # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      end
    }))
  end

  def render_head_comment(_bld, _pComponent)
    utils = get_default_utils

    utils.render_block_comment
  end
end
