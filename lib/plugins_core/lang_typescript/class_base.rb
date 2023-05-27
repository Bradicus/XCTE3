require "plugins_core/lang_typescript/plugin_base"
require "x_c_t_e_plugin"
require "x_c_t_e_class_base"

# This class contains functions that may be usefull in any type of class
module XCTETypescript
  class ClassBase < XCTEClassBase
    def get_default_utils
      return Utils.instance
    end

    def getStyledFileName(uName)
      return Utils.instance.getStyledFileName(uName)
    end

    def getStyledClassName(uName)
      return Utils.instance.getStyledClassName(uName)
    end

    def get_relative_route(cls, actionName)
      route = Array.new

      if cls.for != nil
        route.push(cls.for)
      end

      if (!cls.model.name.include?(actionName))
        route.push(Utils.instance.getStyledUrlName(cls.model.name) + "-" + actionName)
      else
        route.push(Utils.instance.getStyledUrlName(cls.model.name))
      end

      return route
    end

    def get_full_route(cls, actionName)
      route = Array.new

      if cls.featureGroup != nil
        route.push(cls.featureGroup)
      else
        route.push(cls.model.name)
      end

      return route + get_relative_route(cls, actionName)
    end

    def process_dependencies(cls, bld)
      # Generate dependency code for functions
      for fun in cls.functions
        process_fuction_dependencies(cls, bld, fun)
      end
    end

    def process_fuction_dependencies(cls, bld, fun)
      if fun.elementId == CodeElem::ELEM_FUNCTION
        templ = XCTEPlugin::findMethodPlugin("typescript", fun.name)
        if templ != nil
          templ.process_dependencies(cls, bld)
        else
          #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      end
    end

    def render_dependencies(cls, bld)
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
