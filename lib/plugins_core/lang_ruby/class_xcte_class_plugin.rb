##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "XCTEPlugin" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require "x_c_t_e_plugin"
require "plugins_core/lang_ruby/utils"
require "plugins_core/lang_ruby/source_renderer_ruby"
require "plugins_core/lang_ruby/x_c_t_e_ruby"

require "code_structure/code_elem_parent"
require "code_structure/code_elem_model"
require "lang_file"

module XCTERuby
  class ClassXCTEClassPlugin < ClassBase
    def initialize
      @name = "xcte_class_plugin"
      @language = "ruby"
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererRuby.new
      bld.lfName = Utils.instance.style_as_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.get_extension("body")
      render_file_comment(cls, bld)
      render_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    def render_file_comment(cls, bld)
      bld.add("##")
      bld.add("# Class:: " + get_class_name(cls))

      bld.add("# Author:: " + UserSettings.instance.codeAuthor) if !UserSettings.instance.codeAuthor.nil?

      if !UserSettings.instance.codeCompany.nil? && UserSettings.instance.codeCompany.size > 0
        bld.add("# " + UserSettings.instance.codeCompany)
      end

      if !UserSettings.instance.codeLicense.nil? && UserSettings.instance.codeLicense.strip.size > 0
        bld.add("#")
        bld.add("# License:: " + UserSettings.instance.codeLicense)
      end

      bld.add("#")

      # if (UserSettings.instance.description != nil)
      #   UserSettings.instance.description.each_line { |descLine|
      #     if descLine.strip.size > 0
      #       headerString.add("# " + descLine.chomp)
      #     end
      #   }
      # end
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      for inc in cls.includes
        bld.add("require '" + inc.path + inc.name + "." + Utils.instance.get_extension("body") + "'")
      end

      bld.add if !cls.includes.empty?

      # Process namespace items
      if cls.namespace.hasItems?
        for nsItem in cls.namespace.ns_list
          bld.start_block("module " << nsItem)
        end
      end

      bld.start_class("class " + get_class_name(cls) + " < ClassBase")

      bld.start_function("def initialize")
      bld.add('@name = "' + CodeNameStyling.styleUnderscoreLower(cls.get_u_name) + '"')
      bld.add('@language = "' + cls.language + '"')
      bld.add("@category = XCTEPlugin::CAT_CLASS")
      bld.add('@author = "' + UserSettings.instance.codeAuthor + '"') if UserSettings.instance.codeAuthor
      bld.endFunction
      bld.separate

      bld.start_function("def get_unformatted_class_name(cls)")
      bld.add("return cls.get_u_name()")
      bld.endFunction

      bld.add

      bld.start_function("def gen_source_files(cls)")
      bld.add("srcFiles = Array.new")
      bld.separate
      bld.add("bld = SourceRenderer" +
              CodeNameStyling.getStyled(cls.language, "PASCAL_CASE") + ".new")
      bld.add("bld.lfName = Utils.instance.style_as_file_name(get_unformatted_class_name(cls))")
      bld.add("bld.lfExtension = Utils.instance.get_extension('body')")
      bld.separate
      bld.add("process_dependencies(cls)")
      bld.add("render_dependencies(cls, bld)")
      bld.separate
      bld.add("render_file_comment(cls, bld)")
      bld.add("render_body_content(cls, bld)")
      bld.add
      bld.add("srcFiles << bld")
      bld.add
      bld.add("return srcFiles")
      bld.endFunction
      bld.add

      bld.add("# Returns the code for the comment for this class")
      bld.start_function("def render_file_comment(cls, bld)")
      bld.add
      bld.endFunction
      bld.add

      bld.add("# Returns the code for the content for this class")
      bld.start_function("def render_body_content(cls, bld)")

      bld.add('bld.start_class("class " + get_class_name(cls))')
      bld.separate
      bld.add("bld.separate")

      bld.add("# Generate code for class variables")
      bld.add("each_var(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|")
      bld.add("}))")

      bld.separate
      bld.add("bld.separate")

      bld.add("# Generate code for functions")
      bld.add("render_functions(cls, bld)")

      bld.separate

      bld.add("bld.end_class")
      bld.endFunction
      bld.add

      bld.separate

      bld.end_block

      # Process namespace items
      if cls.namespace.hasItems?
        for nsItem in cls.namespace.ns_list
          bld.end_block
        end
      end

      bld.separate

      prefix = cls.namespace.get("::")

      prefix += "::" if prefix.size > 0

      bld.add("XCTEPlugin::registerPlugin(" + prefix + get_class_name(cls) + ".new)")
    end
  end
end

XCTEPlugin.registerPlugin(XCTERuby::ClassXCTEClassPlugin.new)
