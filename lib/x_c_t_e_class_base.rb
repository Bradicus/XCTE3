require "x_c_t_e_plugin"
require "params/render_fun_def_params"

# Base class for all class plugins
class XCTEClassBase < XCTEPlugin
  def getClassName(cls)
    return get_default_utils().getStyledClassName(getUnformattedClassName(cls))
  end

  def get_default_utils
    throw :required_implimentation
  end

  def getDependencyPath(cls)
    fileName = get_default_utils().getStyledFileName(getUnformattedClassName(cls))

    if cls.path != nil
      depPath = cls.path + "/" + fileName
    else
      depPath = cls.namespace.get("/") + "/" + fileName
    end

    return depPath
  end

  def render_functions(cls, bld)
    get_default_utils().eachFun(UtilsEachFunParams.new(cls, bld, lambda { |fun|
      if fun.isTemplate
        templ = XCTEPlugin::findMethodPlugin(get_default_utils().langProfile.name, fun.name)
        if templ != nil
          templ.get_definition(cls, bld, fun)
        else
          #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      else # Must be empty function
        templ = XCTEPlugin::findMethodPlugin(get_default_utils().langProfile.name, "method_empty")
        if templ != nil
          templ.get_definition(cls, bld, fun)
        else
          #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      end
    }))
  end
end
