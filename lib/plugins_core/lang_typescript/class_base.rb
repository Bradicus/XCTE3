require "plugins_core/lang_typescript/plugin_base.rb"
require "x_c_t_e_plugin.rb"

# This class contains functions that may be usefull in any type of class
module XCTETypescript
  class ClassBase < PluginBase
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
      cls.includes.sort_by! do |x|
        [x.path, x.name]
      end

      for inc in cls.includes
        path = inc.path

        if !inc.path.start_with?("@") && inc.itype != "lib"
          clsPaths = cls.path.split("/")
          incPaths = inc.path.split("/")

          path = ""

          while (clsPaths.length > 0 && incPaths.length > 0 && clsPaths[0] == incPaths[0])
            clsPaths.shift
            incPaths.shift
          end

          if (clsPaths.length == 0)
            path = "./"
          else
            for cp in clsPaths
              path += "../"
            end
          end

          path += incPaths.join("/")
        end

        bld.add("import { " + inc.name + " } from '" + path + "';")
      end
    end
  end
end
