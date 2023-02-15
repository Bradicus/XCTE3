require "plugins_core/lang_java/utils.rb"
require "x_c_t_e_class_base.rb"

# This class contains functions that may be usefull in any type of class
module XCTEJava
  class ClassBase < XCTEClassBase
    def get_default_utils
      return Utils.instance
    end

    def process_dependencies(cls, bld)
      # Generate dependency code for functions
      for fun in cls.functions
        process_fuction_dependencies(cls, bld, fun)
      end

      if (cls.dataClass != nil)
        Utils.instance.requires_class_ref(cls, cls.dataClass)
        #  Utils.instance.requires_class_type(cls, cls.dataClass, "standard")
      end
    end

    def process_fuction_dependencies(cls, bld, fun)
      if fun.elementId == CodeElem::ELEM_FUNCTION
        templ = XCTEPlugin::findMethodPlugin(get_default_utils().langProfile.name, fun.name)
        if templ != nil
          templ.process_dependencies(cls, bld, fun)
        else
          #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      end
    end

    def render_dependencies(cls, bld)
      bld.separateIf(cls.uses.length > 0)

      for use in cls.uses
        bld.add("import " + use.namespace.get(".") + ";")

        # if inc.itype == "<"
        #   bld.add("#include <" << incPathAndName << ">")
        # elsif inc.name.count(".") > 0
        #   bld.add('#include "' << incPathAndName << '"')
        # else
        #   bld.add('#include "' << incPathAndName << "." << Utils.instance.getExtension("header") << '"')
        # end
      end

      bld.separateIf(cls.uses.length > 0)
    end

    def render_package_start(cls, bld)
      # Process namespace items
      if cls.namespace.hasItems?()
        bld.add("package " + cls.namespace.get(".") + ";")
        bld.separate
      end
    end

    def render_header_var_group_getter_setters(cls, bld)
      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if (var.genGet)
          templ = XCTEPlugin::findMethodPlugin("java", "method_get")
          if templ != nil
            templ.get_definition(var, bld)
          end
        end
        if (var.genSet)
          templ = XCTEPlugin::findMethodPlugin("java", "method_set")
          if templ != nil
            templ.get_definition(var, bld)
          end
        end
      }))
    end
  end
end
