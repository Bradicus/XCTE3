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

module XCTECpp
  class ClassJsonEngine < ClassBase
    def initialize
      @name = "json_engine"
      @language = "cpp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name + " json engine"
    end

    def gen_source_files(cls)
      srcFiles = []

      hBld = SourceRendererCpp.new
      hBld.lfName = Utils.instance.style_as_file_name(get_unformatted_class_name(cls))
      hBld.lfExtension = Utils.instance.get_extension("header")
      render_header_comment(cls, hBld)
      render_header(cls, hBld)

      bBld = SourceRendererCpp.new
      bBld.lfName = Utils.instance.style_as_file_name(get_unformatted_class_name(cls))
      bBld.lfExtension = Utils.instance.get_extension("body")
      render_header_comment(cls, bBld)
      render_body_content(cls, bBld)

      srcFiles << hBld
      srcFiles << bBld

      srcFiles
    end

    def render_header_comment(cls, bld)
      cfg = UserSettings.instance

      bld.add("/**")
      bld.add("* @class " + Utils.instance.style_as_class(cls.get_u_name + "JsonEngine"))

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
      render_ifndef(cls, bld)

      # get list of includes needed by functions

      render_fun_dependencies(cls, bld)
      render_dependencies(cls, bld)

      bld.add if cls.includes.length > 0

      # Process namespace items
      if cls.namespace.hasItems?
        for nsItem in cls.namespace.ns_list
          bld.start_block("namespace " << nsItem)
        end
        bld.add
      end

      classDec = "class " + get_class_name(cls)

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

          classDec += cls.base_classes[par].visibility + " " + nameSp + Utils.instance.style_as_class(cls.base_classes[par].name)
        end
      end

      bld.start_class(classDec)

      bld.add("public:")
      bld.indent

      render_function_declairations(cls, bld)

      bld.unindent

      bld.end_class

      # Process namespace items
      if cls.namespace.hasItems?
        cls.namespace.ns_list.reverse_each do |nsItem|
          bld.end_block("  // namespace " << nsItem)
        end
        bld.add
      end

      bld.add("#endif")
    end

    # Returns the code for the body for this class
    def render_body_content(cls, bld)
      bld.add('#include "' << Utils.instance.style_as_class(cls.get_u_name + "JsonEngine") << '.h"')
      bld.separate

      render_namespace_start(cls, bld)
      render_functions(cls, bld)
      render_namespace_end(cls, bld)
    end
  end
end

XCTEPlugin.registerPlugin(XCTECpp::ClassJsonEngine.new)
