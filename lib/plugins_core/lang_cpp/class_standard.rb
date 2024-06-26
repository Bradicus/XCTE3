##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "class_standard" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require "plugins_core/lang_cpp/utils"
require "plugins_core/lang_cpp/method_empty"
require "plugins_core/lang_cpp/x_c_t_e_cpp"

require "code_structure/code_elem_parent"
require "lang_file"
require "x_c_t_e_plugin"
require "log"

module XCTECpp
  class ClassStandard < ClassBase
    def initialize
      @name = "class_standard"
      @language = "cpp"
      @category = XCTEPlugin::CAT_CLASS
      @activeVisibility = ""
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name
    end

    def render_header_comment(cls, bld)
      cfg = UserSettings.instance

      bld.add("/**")
      bld.add("* @class " + Utils.instance.style_as_class(cls.get_u_name))

      bld.add("* @author " + cfg.codeAuthor) if !UserSettings.instance.codeAuthor.nil?

      bld.add("* " + cfg.codeCompany) if !UserSettings.instance.codeCompany.nil? && cfg.codeCompany.size > 0

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
      @activeVisibility = ""
      render_ifndef(cls, bld)

      # get list of includes needed by functions

      # Generate function dependencies
      render_fun_dependencies(cls, bld)
      render_dependencies(cls, bld)

      bld.add if cls.includes.length > 0

      render_namespace_start(cls, bld)

      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.arrayElemCount > 0
          bld.add("#define " << Utils.instance.get_size_const(var) << " " << var.arrayElemCount.to_s)
        end
      }))

      bld.separate if Utils.instance.has_an_array?(cls)

      for pd in cls.pre_defs
        bld.add("class " + pd + ";")
      end

      classDec = "class " + Utils.instance.style_as_class(cls.get_u_name)

      inheritFrom = []

      for b_cls_ref in cls.base_classes
        inheritFrom.push("public " + dutils.get_class_ref_type(cls, b_cls_ref))
      end

      for icls in cls.interfaces
        i_pas = Utils.instance.get_plugin_and_spec_for_ref(cls, icls)

        if i_pas.valid?
          inheritFrom.push("public" + " " + i_pas.plugin.get_class_name(i_pas.spec))
        else # If this class isn't made by us
          inheritFrom.push("public" + " " + Utils.instance.style_as_class(icls.model_name))
        end
      end

      classDec += " : " + inheritFrom.join(", ") if inheritFrom.length > 0

      bld.start_class(classDec)

      bld.indent

      # Generate class variables
      process_header_var_group(cls, bld, cls.model.varGroup, "public")

      bld.separate

      process_header_var_group(cls, bld, cls.model.varGroup, "private")

      bld.separate

      # Generate function declarations
      for funItem in cls.functions
        fp_params = FunPluginParams.new().w_bld(bld).w_cls(cls).w_cplug(self).w_fun(funItem)

        if funItem.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION
          if funItem.visibility != @activeVisibility
            @activeVisibility = funItem.visibility
            bld.unindent
            bld.add(funItem.visibility + ":")
            bld.indent
          end

          if funItem.isTemplate
            templ = PluginManager.find_method_plugin("cpp", funItem.name)
            if !templ.nil?
              if funItem.isInline
                templ.render_declaration_inline(fp_params)
              else
                templ.render_declaration(fp_params)
              end
            else
              # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end
          else # Must be an empty function
            templ = PluginManager.find_method_plugin("cpp", "method_empty")
            if !templ.nil?
              if funItem.isInline
                templ.render_declaration_inline(fp_params)
              else
                templ.render_declaration(fp_params)
              end
            else
              # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end
          end
        elsif funItem.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
          bld.add(Utils.instance.get_comment(funItem))
        elsif funItem.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
          if funItem.formatText == "\n"
            bld.add
          else
            bld.same_line(funItem.formatText)
          end
        end
      end

      process_header_var_group_getter_setters(cls, bld, cls.model.varGroup)

      bld.separate

      bld.unindent

      bld.add("//+XCTE Custom Code Area")
      bld.add
      bld.add("//-XCTE Custom Code Area")

      bld.end_class

      render_namespace_end(cls, bld)

      bld.add("#endif")
    end

    # process variable group
    def process_header_var_group(cls, bld, _vGroup, vis)
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.visibility != @activeVisibility
          @activeVisibility = var.visibility
          bld.unindent
          bld.add(var.visibility + ":")
          bld.indent
        end

        if vis == var.visibility
          bld.add(Utils.instance.get_var_dec(var))
        end
      }))
    end

    def process_header_var_group_getter_setters(cls, bld, vGroup)
      for var in vGroup.vars
        if "public" != @activeVisibility
          @activeVisibility = "public"
          bld.unindent
          bld.add("public:")
          bld.indent
        end

        if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
          if var.genGet
            templ = PluginManager.find_method_plugin("cpp", "method_get")
            templ.render_declaration(var, bld) if !templ.nil?
          end
          if var.genSet
            templ = PluginManager.find_method_plugin("cpp", "method_set")
            templ.render_declaration(var, bld) if !templ.nil?
          end
        end
      end

      for group in vGroup.varGroups
        process_header_var_group_getter_setters(cls, bld, group)
      end
    end

    # Returns the code for the body for this class
    def render_body_content(cls, bld)
      bld.add('#include "' << Utils.instance.style_as_class(cls.get_u_name) << '.h"')
      bld.add

      render_namespace_start(cls, bld)

      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.isStatic
          bld.add(Utils.instance.get_type_name(var) << " ")
          bld.same_line(Utils.instance.style_as_class(cls.get_u_name) << " :: ")
          bld.same_line(Utils.instance.get_styled_variable_name(var))

          if var.arrayElemCount.to_i > 0 # This is an array
            bld.same_line("[" + Utils.instance.get_size_const(var) << "]")
          elsif !var.defaultValue.nil?
            bld.same_line(" = " + var.defaultValue)
          end

          bld.same_line(";")
        end
      }))

      bld.separate

      render_functions(cls, bld)

      bld.add("//+XCTE Custom Code Area")
      bld.add
      bld.add("//-XCTE Custom Code Area")

      render_namespace_end(cls, bld)
    end
  end
end

XCTEPlugin.registerPlugin(XCTECpp::ClassStandard.new)
