##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for a json_engine classes

require "plugins_core/lang_cpp/utils.rb"
require "plugins_core/lang_cpp/method_empty.rb"
require "plugins_core/lang_cpp/x_c_t_e_cpp.rb"
require "code_elem.rb"
require "code_elem_parent.rb"
require "lang_file.rb"
require "x_c_t_e_plugin.rb"

module XCTECpp
  class ClassJsonEngine < ClassBase
    def initialize
      @name = "json_engine"
      @language = "cpp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " json engine"
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      cls.setName(getUnformattedClassName(cls))

      bld = SourceRendererCpp.new
      bld.lfName = Utils.instance.getStyledFileName(cls.getUName() + "JsonEngine")
      bld.lfExtension = Utils.instance.getExtension("header")
      genHeaderComment(cls, bld)
      genHeader(cls, bld)

      bld = SourceRendererCpp.new
      bld.lfName = Utils.instance.getStyledFileName(cls.getUName() + "JsonEngine")
      bld.lfExtension = Utils.instance.getExtension("body")
      genHeaderComment(cls, bld)
      genBody(cls, bld)

      srcFiles << bld
      srcFiles << bld

      return srcFiles
    end

    def genHeaderComment(cls, bld)
      cfg = UserSettings.instance

      bld.add("/**")
      bld.add("* @class " + Utils.instance.getStyledClassName(cls.getUName() + "JsonEngine"))

      if (cfg.codeAuthor != nil)
        bld.add("* @author " + cfg.codeAuthor)
      end

      if cfg.codeCompany != nil && cfg.codeCompany.size > 0
        bld.add("* " + cfg.codeCompany)
      end

      if cfg.codeLicense != nil && cfg.codeLicense.strip.size > 0
        bld.add("*")
        bld.add("* " + cfg.codeLicense)
      end

      bld.add("* ")

      if (cls.model.description != nil)
        cls.model.description.each_line { |descLine|
          if descLine.strip.size > 0
            bld.add("* " << descLine.strip)
          end
        }
      end

      bld.add("*/")
    end

    # Returns the code for the header for this class
    def genHeader(cls, bld)
      render_ifndef(cls, bld)

      # get list of includes needed by functions

      render_fun_dependencies(cls, bld)
      render_dependencies(cls, bld)

      if cls.includes.length > 0
        bld.add
      end

      # Process namespace items
      if cls.namespace.hasItems?()
        for nsItem in cls.namespace.nsList
          bld.startBlock("namespace " << nsItem)
        end
        bld.add
      end

      classDec = "class " + Utils.instance.getDerivedClassPrefix(cls)

      for par in (0..cls.baseClassPluginManager.size)
        nameSp = ""
        if par == 0 && cls.baseClasses[par] != nil
          classDec << " : "
        elsif cls.baseClasses[par] != nil
          classDec << ", "
        end

        if cls.baseClasses[par] != nil
          if cls.baseClasses[par].namespace.hasItems?() && cls.baseClasses[par].namespace.nsList.size > 0
            nameSp = cls.baseClasses[par].namespace.get("::") + "::"
          end

          classDec << cls.baseClasses[par].visibility << " " << nameSp << Utils.instance.getStyledClassName(cls.baseClasses[par].name)
        end
      end

      bld.startClass(classDec)

      bld.add("public:")
      bld.indent

      render_function_declairations(cls, bld)

      bld.unindent

      bld.endClass

      # Process namespace items
      if cls.namespace.hasItems?()
        cls.namespace.nsList.reverse_each do |nsItem|
          bld.endBlock("  // namespace " << nsItem)
        end
        bld.add
      end

      bld.add("#endif")
    end

    # Returns the code for the body for this class
    def genBody(cls, bld)
      bld.add("#include \"" << Utils.instance.getStyledClassName(cls.getUName() + "JsonEngine") << '.h"')
      bld.add

      render_namespace_start(cls, bld)
      render_functions(cls, bld)
      render_namespace_end(cls, bld)
    end
  end
end

XCTEPlugin::registerPlugin(XCTECpp::ClassJsonEngine.new)
