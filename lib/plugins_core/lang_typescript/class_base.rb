require 'plugins_core/lang_typescript/plugin_base'
require 'x_c_t_e_plugin'
require 'x_c_t_e_class_base'

# This class contains functions that may be usefull in any type of class
module XCTETypescript
  class ClassBase < XCTEClassBase
    def get_default_utils
      return Utils.instance
    end

    def get_source_renderer
      return SourceRendererTypescript.new
    end

    def render_namespace_start(cls, bld)
      if !ActiveComponent.get().ignore_namespace
        for ns in cls.namespace.nsList
          bld.start_block('export namespace ' + get_default_utils().get_styled_namespace_name(ns))
        end
      end
    end

    def render_namespace_end(cls, bld)
      if !ActiveComponent.get().ignore_namespace
        for ns in cls.namespace.nsList
          bld.end_block
        end
      end
    end

    def get_styled_file_name(uName)
      return Utils.instance.get_styled_file_name(uName)
    end

    def get_styled_class_name(uName)
      return Utils.instance.get_styled_class_name(uName)
    end

    def get_relative_route(cls, actionName)
      route = []

      route.push(cls.variant) if !cls.variant.nil?

      if !cls.model.name.include?(actionName)
        route.push(Utils.instance.getStyledUrlName(cls.model.name) + '-' + actionName)
      else
        route.push(Utils.instance.getStyledUrlName(cls.model.name))
      end

      return route
    end

    def get_full_route(cls, actionName)
      route = []

      if !cls.featureGroup.nil?
        route.push(cls.featureGroup)
      else
        route.push(cls.model.name)
      end

      return '/' + (route + get_relative_route(cls, actionName)).join('/')
    end

    def process_dependencies(cls, bld)
      # Generate dependency code for functions
      for fun in cls.functions
        process_fuction_dependencies(cls, bld, fun)
      end
    end

    def process_fuction_dependencies(cls, bld, fun)
      return unless fun.elementId == CodeElem::ELEM_FUNCTION

      templ = XCTEPlugin.findMethodPlugin('typescript', fun.name)
      if !templ.nil?
        templ.process_dependencies(cls, bld)
      else
        # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
      end
    end

    def render_dependencies(cls, bld)
      cls.includes.sort_by! do |x|
        [x.path, x.name]
      end

      for inc in cls.includes
        path = inc.path

        if !inc.path.start_with?('@') && inc.itype != 'lib'
          clsPaths = cls.path.split('/')
          incPaths = inc.path.split('/')

          path = ''

          while clsPaths.length > 0 && incPaths.length > 0 && clsPaths[0] == incPaths[0]
            clsPaths.shift
            incPaths.shift
          end

          if clsPaths.length == 0
            path = './'
          else
            for cp in clsPaths
              path += '../'
            end
          end

          path += incPaths.join('/')
        end

        bld.add('import { ' + inc.name + " } from '" + get_default_utils().get_styled_directory_name(path) + "';")
      end
    end
  end
end
