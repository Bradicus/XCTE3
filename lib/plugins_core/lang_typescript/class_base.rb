require "plugins_core/lang_typescript/utils.rb"
require "x_c_t_e_plugin.rb"

# This class contains functions that may be usefull in any type of class
module XCTETypescript
  class ClassBase < XCTEPlugin
    def process_dependencies(cls, cfg, bld)
      # Generate dependency code for functions
      for fun in cls.functions
        process_fuction_dependencies(cls, cfg, bld, fun)
      end
    end

    def process_fuction_dependencies(cls, cfg, bld, fun)
      if fun.elementId == CodeElem::ELEM_FUNCTION
        templ = XCTEPlugin::findMethodPlugin("typescript", fun.name)
        if templ != nil
          templ.process_dependencies(cls, cfg, bld)
        else
          #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      end
    end

    def render_dependencies(cls, cfg, bld)
      for inc in cls.includes
        bld.add("import { " + inc.name + " } from '" + inc.path + "';")
      end
    end
  end
end
