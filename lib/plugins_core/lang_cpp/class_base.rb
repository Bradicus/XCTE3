require "plugins_core/lang_cpp/utils"
require "x_c_t_e_class_base"

# This class contains functions that may be usefull in any type of class
module XCTECpp
  class ClassBase < XCTEClassBase
    def render_ifndef(cls, bld)
      if cls.namespace.hasItems?
        bld.add("#ifndef __" + cls.namespace.get("_") + "_" + Utils.instance.style_as_class(cls.get_u_name) + "_H")
        bld.add("#define __" + cls.namespace.get("_") + "_" + Utils.instance.style_as_class(cls.get_u_name) + "_H")
        bld.add
      else
        bld.add("#ifndef __" + cls.get_u_name + "_H")
        bld.add("#define __" + cls.get_u_name + "_H")
        bld.add
      end
    end

    def get_default_utils
      return Utils.instance
    end

    def render_dependencies(cls, bld)
      addAutoIncludes(cls)

      for inc in cls.includes
        if inc.path.length > 0
          incPathAndName = inc.path + "/" + inc.name
        else
          incPathAndName = inc.name
        end

        if inc.itype == "<"
          bld.add("#include <" << incPathAndName << ">")
        elsif inc.name.count(".") > 0
          bld.add('#include "' << incPathAndName << '"')
        else
          bld.add('#include "' << incPathAndName << "." << Utils.instance.get_extension("header") << '"')
        end
      end
    end

    def render_fun_dependencies(cls, bld)
      # Get dependencies for functions
      for fun in cls.functions
        if fun.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION && fun.isTemplate
          templ = XCTEPlugin.findMethodPlugin("cpp", fun.name)
          if !templ.nil?
            templ.process_dependencies(cls, bld, fun)
          else
            # puts 'ERROR no plugin for function: ' << fun.name << '   language: cpp'
          end
        end
      end
    end

    def render_function_declairations(cls, bld)
      Utils.instance.each_fun(UtilsEachFunParams.new(cls, bld, lambda { |fun|
        fp_params = FunPluginParams.new().w_bld(bld).w_cls(cls).w_cplug(self).w_fun(fun)
        if fun.isTemplate
          templ = XCTEPlugin.findMethodPlugin("cpp", fun.name)
          if !templ.nil?
            if fun.isInline
              templ.render_declaration_inline(fp_params)
            else
              templ.render_declaration(fp_params)
            end
          else
            # puts 'ERROR no plugin 4 function: ' << fun.name << '   language: cpp'
          end
        else # Must be an empty function
          templ = XCTEPlugin.findMethodPlugin("cpp", "method_empty")
          if !templ.nil?
            if fun.isInline
              templ.render_declaration_inline(fp_params)
            else
              templ.render_declaration(fp_params)
            end
          else
            # puts 'ERROR no plugin 4 function: ' << fun.name << '   language: cpp'
          end
        end
      }))
    end

    def render_uses(cls, bld)
      for us in cls.uses
        bld.add("using namespace " + us.namespace.get("::") + ";")
      end
    end

    def render_namespace_start(cls, bld)
      # Process namespace items
      return unless cls.namespace.hasItems?

      for nsItem in cls.namespace.ns_list
        bld.start_block("namespace " << nsItem)
      end
    end

    def render_namespace_end(cls, bld, nsCloseChar = "")
      # Process namespace items
      return unless cls.namespace.hasItems?

      cls.namespace.ns_list.reverse_each do |nsItem|
        bld.end_block(nsCloseChar + "  // namespace " + nsItem)
      end
    end

    def addAutoIncludes(cls)
      # Process variables
      each_var(uevParams.wCls(cls).wSeparate(false).wVarCb(lambda { |var|
        if var.respond_to? :vtype
          varTypeMap = Utils.instance.get_type(var.vtype)
          if !varTypeMap.nil? && !varTypeMap.autoInclude.name.nil? && !varTypeMap.autoInclude.name.empty?
            cls.addInclude(varTypeMap.autoInclude.path, varTypeMap.autoInclude.name, varTypeMap.autoInclude.itype)
          end
        end
      }))
    end
  end
end
