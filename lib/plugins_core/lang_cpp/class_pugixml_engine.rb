##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for a json_engine classes

require "plugins_core/lang_cpp/utils"
require "plugins_core/lang_cpp/method_empty"
require "plugins_core/lang_cpp/x_c_t_e_cpp"

require "code_structure/code_elem_parent"
require "lang_file"
require "x_c_t_e_plugin"
require "log"

module XCTECpp
  class ClassPugiXmlEngine < ClassBase
    def initialize
      @name = "pugixml_engine"
      @language = "cpp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.model.name + " pugi xml engine"
    end

    def process_dependencies(cls_spec, bld)
      super

      Utils.instance.try_add_include_for(cls, cls, "class_standard")
    end

    def render_header_comment(cls, bld)
      cfg = UserSettings.instance

      bld.add("/**")
      bld.add("* @class " + get_class_name(cls))
      bld.add("* " + cfg.codeCompany) if !cfg.codeCompany.nil? && cfg.codeCompany.size > 0

      if !cfg.codeLicense.nil? && cfg.codeLicense.strip.size > 0
        bld.add("*")
        bld.add("* " + cfg.codeLicense)
      end

      bld.add("* ")

      if !cls.model.description.nil?
        cls.model.description.each_line do |descLine|
          bld.add("* " << descLine.strip) if descLine.strip.size > 0
        end
      end

      bld.add("*/")
    end

    # Returns the code for the header for this class
    def render_header(cls, bld)
      render_ifndef(cls, bld)

      # get list of includes needed by functions

      # Generate function declarations
      for funItem in cls.functions
        if funItem.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION && funItem.isTemplate
          templ = PluginManager.find_method_plugin("cpp", funItem.name)
          if !templ.nil?
            templ.process_dependencies(cls, funItem, bld)
          else
            # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
          end
        end
      end

      render_dependencies(cls, bld)

      bld.add if cls.includes.length > 0

      # Process namespace items
      if cls.namespace.hasItems?
        for nsItem in cls.namespace.ns_list
          bld.start_block("namespace " << nsItem)
        end
        bld.add
      end

      # Do automatic static array size declairations above class def

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.arrayElemCount > 0
          bld.add("#define " << Utils.instance.get_size_const(var) << " " << var.arrayElemCount.to_s)
        end
      }))

      bld.separate if Utils.instance.has_an_array?(cls)

      classDec = "class " + cls.get_u_name

      for par in (0..cls.base_classes.size)
        nameSp = ""
        if par == 0 && !cls.base_classes[par].nil?
          classDec << " : "
        elsif !cls.base_classes[par].nil?
          classDec << ", "
        end

        if !cls.base_classes[par].nil?
          if cls.base_classes[par].namespace.hasItems? && cls.base_classes[par].namespace.ns_list.size > 0
            nameSp = cls.base_classes[par].namespace.get("::") + "::"
          end

          classDec << cls.base_classes[par].visibility << " " << nameSp << Utils.instance.style_as_class(cls.base_classes[par].name)
        end
      end

      bld.start_class(classDec)

      bld.add("public:")
      bld.indent

      # Generate class variables

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        bld.add(Utils.instance.get_var_dec(var)) if var.arrayElemCount > 0
      }))

      bld.add if cls.functions.length > 0

      render_function_declairations(cls, bld)

      bld.unindent

      bld.end_class

      render_namespace_end(cls, bld)

      bld.separate
      bld.add("#endif")
    end

    # Returns the code for the body for this class
    def render_body_content(cls, bld)
      bld.add('#include "' << Utils.instance.style_as_class(cls.get_u_name) << '.h"')
      bld.separate

      render_namespace_start(cls, bld)

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && var.isStatic
          bld.add(Utils.instance.get_type_name(var) << " ")
          bld.same_line(Utils.instance.style_as_class(cls.get_u_name) << " :: ")
          bld.same_line(Utils.instance.get_styled_variable_name(var))

          if var.arrayElemCount.to_i > 0 # This is an array
            bld.same_line("[" + Utils.instance.get_size_const(var) << "]")
          end

          bld.same_line(";")
        end
      }))

      bld.separate

      render_functions(cls, bld)

      render_namespace_end(cls, bld)
    end
  end
end

XCTEPlugin.registerPlugin(XCTECpp::ClassPugiXmlEngine.new)
