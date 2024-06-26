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

module XCTECpp
  class EnumStandard < ClassBase
    def initialize
      @name = "enum"
      @language = "cpp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererCpp.new
      bld.lfName = Utils.instance.style_as_file_name(cls.get_u_name)
      bld.lfExtension = Utils.instance.get_extension("header")
      render_header_comment(cls, bld)
      render_header(cls, bld)

      srcFiles << bld

      srcFiles
    end

    def render_header_comment(cls, bld)
      cfg = UserSettings.instance

      bld.add("/**")
      bld.add("* @enum " + cls.get_u_name)

      bld.add("* @author " + cfg.codeAuthor) if !cfg.codeAuthor.nil?

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
      if cls.namespace.hasItems?
        bld.add("#ifndef __" + cls.namespace.get("_") + "_" + Utils.instance.style_as_class(cls.get_u_name) + "_H")
        bld.add("#define __" + cls.namespace.get("_") + "_" + Utils.instance.style_as_class(cls.get_u_name) + "_H")
        bld.add
      else
        bld.add("#ifndef __" + Utils.instance.style_as_class(cls.get_u_name) + "_H")
        bld.add("#define __" + Utils.instance.style_as_class(cls.get_u_name) + "_H")
        bld.add
      end

      render_namespace_start(cls, bld)

      # Do automatic static array size declairations above class def

      classDec = "enum class " + Utils.instance.style_as_class(cls.get_u_name)

      bld.start_block(classDec)
      enums = []

      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        enumDec = Utils.instance.style_as_enum(var.name)
        enumDec += " = " + var.defaultValue if !var.defaultValue.nil?
        enums.push(enumDec)
      }))

      first = true
      for enum in enums
        if first
          bld.add(enum)
          first = false
        else
          bld.same_line(",")
          bld.add(enum)
        end
      end

      bld.end_block(";")

      render_namespace_end(cls, bld)

      bld.separate
      bld.add("#endif")
    end
  end
end

XCTEPlugin.registerPlugin(XCTECpp::EnumStandard.new)
