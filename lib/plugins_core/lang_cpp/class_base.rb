require "plugins_core/lang_cpp/utils"
require "x_c_t_e_class_base"

# This class contains functions that may be usefull in any type of class
module XCTECpp
  class ClassBase < XCTEClassBase
    def render_ifndef(cls, bld)
      if cls.namespace.hasItems?
        bld.add("#ifndef __" + cls.namespace.get("_") + "_" + get_class_name(cls) + "_H")
        bld.add("#define __" + cls.namespace.get("_") + "_" + get_class_name(cls) + "_H")
        bld.add
      else
        bld.add("#ifndef __" + get_class_name(cls) + "_H")
        bld.add("#define __" + get_class_name(cls) + "_H")
        bld.add
      end
    end

    def dutils
      return Utils.instance
    end

    def get_source_renderer
      return SourceRendererCpp.new
    end

    def gen_source_files(cls)
      srcFiles = []

      cls.name = get_class_name(cls)

      process_dependencies(cls)

      hBld = get_source_renderer()
      hBld.lfName = Utils.instance.style_as_file_name(get_unformatted_class_name(cls))
      hBld.lfExtension = Utils.instance.get_extension("header")
      render_header_comment(cls, hBld)
      render_header(cls, hBld)

      bBld = get_source_renderer()
      bBld.lfName = Utils.instance.style_as_file_name(get_unformatted_class_name(cls))
      bBld.lfExtension = Utils.instance.get_extension("body")
      render_header_comment(cls, bBld)
      render_body_content(cls, bBld)

      srcFiles << hBld
      srcFiles << bBld

      return srcFiles
    end

    def render_dependencies(cls, bld)
      addAutoIncludes(cls)

      for inc in cls.includes + cls.model.includes
        if inc.path.length > 0
          incPathAndName = inc.path + "/" + inc.name
        else
          incPathAndName = inc.name
        end

        if inc.itype == "<"
          bld.add("#include <" + incPathAndName + ">")
        elsif inc.name.count(".") > 0
          bld.add('#include "' + incPathAndName + '"')
        else
          bld.add('#include "' + incPathAndName + "." + Utils.instance.get_extension("header") + '"')
        end
      end
    end

    def render_fun_dependencies(cls, bld)
      # Get dependencies for functions
      Utils.instance.each_fun(UtilsEachFunParams.new.w_cls(cls).w_bld(bld).w_fun_cb(lambda { |fun|
        templ = PluginManager.find_method_plugin("cpp", fun.name)
        if !templ.nil?
          templ.process_dependencies(cls, fun)
        else
          # puts 'ERROR no plugin for function: ' << fun.name << '   language: cpp'
        end
      }))
    end

    def render_function_declairations(cls, bld)
      Utils.instance.each_fun(UtilsEachFunParams.new.w_cls(cls).w_bld(bld).w_fun_cb(lambda { |fun|
        fp_params = FunPluginParams.new().w_bld(bld).w_cls(cls).w_cplug(self).w_fun(fun)
        if fun.isTemplate
          templ = PluginManager.find_method_plugin("cpp", fun.name)
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
          templ = PluginManager.find_method_plugin("cpp", "method_empty")
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
        bld.start_block("namespace " + nsItem)
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
