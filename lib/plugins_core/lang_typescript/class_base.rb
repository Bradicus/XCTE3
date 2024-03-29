require "plugins_core/lang_typescript/plugin_base"
require "x_c_t_e_plugin"
require "x_c_t_e_class_base"

# This class contains functions that may be usefull in any type of class
module XCTETypescript
  class ClassBase < XCTEClassBase
    def get_default_utils
      return Utils.instance
    end

    def get_source_renderer
      return SourceRendererTypescript.new
    end

    def get_file_name(cls)
      get_default_utils.get_styled_file_name(get_unformatted_class_name(cls))
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = get_file_name(cls)
      bld.lfExtension = Utils.instance.get_extension("body")

      render_file_comment(cls, bld)
      bld.separate
      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

      bld.separate
      render_class_comment(cls, bld)
      render_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    def render_class_comment(cls, bld)
      cfg = UserSettings.instance
      headerString = String.new

      bld.add("/**")
      bld.add("* @class " + get_class_name(cls))

      bld.add("* @author " + cfg.codeAuthor) if !cfg.codeAuthor.nil?

      bld.add("*\n* " + cfg.codeLicense) if !cfg.codeLicense.nil? && cfg.codeLicense.strip.size > 0

      bld.add("* ")

      if !cls.description.nil?
        cls.description.each_line do |descLine|
          bld.add("* " << descLine.chomp) if descLine.strip.size > 0
        end
      end

      bld.add("*/")
    end

    def render_file_comment(cls, bld)
      if ActiveComponent.get().file_comment != nil && ActiveComponent.get().file_comment.length > 0
        bld.comment_file(ActiveComponent.get().file_comment)
      elsif ActiveProject.get().file_comment != nil && ActiveProject.get().file_comment.length > 0
        bld.comment_file(ActiveProject.get().file_comment)
      end
    end

    def render_namespace_start(cls, bld)
      if !ActiveComponent.get().ignore_namespace
        for ns in cls.namespace.ns_list
          bld.start_block("export namespace " + get_default_utils().get_styled_namespace_name(ns))
        end
      end
    end

    def render_namespace_end(cls, bld)
      if !ActiveComponent.get().ignore_namespace
        for ns in cls.namespace.ns_list
          bld.end_block
        end
      end
    end

    def render_class_start(cls, bld)
      base_classes = ""
      if cls.base_classes.length > 0
        base_classes += " extends "
        first = true

        for bc in cls.base_classes
          bc_cls_spec = ClassModelManager.findClass(bc.model_name, bc.plugin_name)
          bc_plugin = XCTEPlugin::findClassPlugin(cls.language, bc.plugin_name)

          if !first
            base_classes += ", "
          end
          base_classes += bc_plugin.get_class_name(bc_cls_spec)
          first = false
        end
      end

      bld.start_class("export class " + get_class_name(cls) + base_classes)
    end

    def include_env_file(cls)
      cls.addInclude("environments/environment", "environment")
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
        route.push(Utils.instance.getStyledUrlName(cls.model.name) + "-" + actionName)
      else
        route.push(Utils.instance.getStyledUrlName(cls.model.name))
      end

      return route
    end

    def get_full_route(cls, actionName)
      route = []

      if !cls.feature_group.nil?
        route.push(cls.feature_group)
      else
        route.push(cls.model.name)
      end

      return (route + get_relative_route(cls, actionName)).join("/")
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

          while clsPaths.length > 0 && incPaths.length > 0 && clsPaths[0] == incPaths[0]
            clsPaths.shift
            incPaths.shift
          end

          if clsPaths.length == 0
            path = "./"
          else
            for cp in clsPaths
              path += "../"
            end
          end

          path += incPaths.join("/")
        end

        bld.add("import { " + inc.name + " } from '" + get_default_utils().get_styled_path_name(path) + "';")
      end
    end
  end
end
