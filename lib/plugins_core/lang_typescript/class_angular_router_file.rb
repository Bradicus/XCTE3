##
# Class:: ClassAngularRouterFile
#
require "active_component"

require "managers/project_plan_manager"
require "plugins_core/lang_typescript/class_angular_component"

module XCTETypescript
  class ClassAngularRouterFile < ClassStandard
    def initialize
      super

      @name = "class_angular_router_file"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name
    end

    def get_file_name(cls)
      return "app.routes"
    end

    def process_dependencies(cls)
      cls.addInclude("@angular/router", "Routes")

      for mdl in ProjectPlanManager.current.models
        for otherCls in mdl.classes
          if otherCls.plug_name.start_with?("class_angular_listing") ||
             otherCls.plug_name.start_with?("class_angular_reactive_edit") ||
             otherCls.plug_name.start_with?("class_angular_reactive_view")
            Utils.instance.try_add_include_for(cls, otherCls, otherCls.plug_name)
          end
        end
      end
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      filePart = Utils.instance.style_as_file_name(cls.get_u_name)

      bld.add "export const routes: Routes = ["
      bld.indent

      routeList = []

      for mdl in ProjectPlanManager.current.models
        for otherCls in mdl.classes
          if otherCls.plug_name.start_with?("class_angular_listing")
            plug = PluginManager.find_class_plugin("typescript", otherCls.plug_name)

            route = plug.get_full_route(otherCls, "listing")

            bld.add("{ path: '" + route + "', component: " + plug.get_class_name(otherCls) + " },")
          elsif otherCls.plug_name.start_with?("class_angular_reactive_edit")
            plug = PluginManager.find_class_plugin("typescript", otherCls.plug_name)

            route = plug.get_full_route(otherCls, "edit")

            bld.add("{ path: '" + route + "/:id', component: " + plug.get_class_name(otherCls) + " },")
          elsif otherCls.plug_name.start_with?("class_angular_reactive_view")
            plug = PluginManager.find_class_plugin("typescript", otherCls.plug_name)

            route = plug.get_full_route(otherCls, "view")

            bld.add("{ path: '" + route + "/:id', component: " + plug.get_class_name(otherCls) + " },")
          end
        end
      end

      bld.unindent
      bld.add "];"
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassAngularRouterFile.new)
