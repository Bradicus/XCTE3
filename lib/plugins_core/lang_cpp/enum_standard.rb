##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "standard" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require "plugins_core/lang_cpp/utils.rb"
require "plugins_core/lang_cpp/method_empty.rb"
require "plugins_core/lang_cpp/x_c_t_e_cpp.rb"
require "code_elem.rb"
require "code_elem_parent.rb"
require "lang_file.rb"
require "x_c_t_e_plugin.rb"

module XCTECpp
  class EnumStandard < ClassBase
    def initialize
      @name = "enum"
      @language = "cpp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName()
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      cls.setName(getUnformattedClassName(cls))

      bld = SourceRendererCpp.new
      bld.lfName = Utils.instance.getStyledFileName(cls.getUName())
      bld.lfExtension = Utils.instance.getExtension("header")
      genHeaderComment(cls, bld)
      genHeader(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def genHeaderComment(cls, bld)
      cfg = UserSettings.instance

      bld.add("/**")
      bld.add("* @enum " + cls.getUName())

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
      if cls.namespace.hasItems?()
        bld.add("#ifndef __" + cls.namespace.get("_") + "_" + Utils.instance.getStyledClassName(cls.getUName()) + "_H")
        bld.add("#define __" + cls.namespace.get("_") + "_" + Utils.instance.getStyledClassName(cls.getUName()) + "_H")
        bld.add
      else
        bld.add("#ifndef __" + Utils.instance.getStyledClassName(cls.getUName()) + "_H")
        bld.add("#define __" + Utils.instance.getStyledClassName(cls.getUName()) + "_H")
        bld.add
      end

      render_namespace_start(cls, bld)

      # Do automatic static array size declairations above class def

      classDec = "enum class " + Utils.instance.getStyledClassName(cls.getUName())

      bld.startBlock(classDec)
      enums = Array.new

      # Process variables
      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        enumDec = Utils.instance.getStyledEnumName(var.name)
        if (var.defaultValue != nil)
          enumDec += " = " + var.defaultValue
        end
        enums.push(enumDec)
      }))

      first = true
      for enum in enums
        if first
          bld.add(enum)
          first = false
        else
          bld.sameLine(",")
          bld.add(enum)
        end
      end

      bld.endBlock(";")

      render_namespace_end(cls, bld)

      bld.separate
      bld.add("#endif")
    end
  end
end

XCTEPlugin::registerPlugin(XCTECpp::EnumStandard.new)
