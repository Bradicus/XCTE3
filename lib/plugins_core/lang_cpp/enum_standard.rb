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

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.getUName()
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      cls.setName(getUnformattedClassName(cls))

      hFile = SourceRendererCpp.new
      hFile.lfName = Utils.instance.getStyledFileName(cls.getUName())
      hFile.lfExtension = Utils.instance.getExtension("header")
      genHeaderComment(cls, cfg, hFile)
      genHeader(cls, cfg, hFile)

      srcFiles << hFile

      return srcFiles
    end

    def genHeaderComment(cls, cfg, hFile)
      hFile.add("/**")
      hFile.add("* @enum " + cls.getUName())

      if (cfg.codeAuthor != nil)
        hFile.add("* @author " + cfg.codeAuthor)
      end

      if cfg.codeCompany != nil && cfg.codeCompany.size > 0
        hFile.add("* " + cfg.codeCompany)
      end

      if cfg.codeLicense != nil && cfg.codeLicense.strip.size > 0
        hFile.add("*")
        hFile.add("* " + cfg.codeLicense)
      end

      hFile.add("* ")

      if (cls.model.description != nil)
        cls.model.description.each_line { |descLine|
          if descLine.strip.size > 0
            hFile.add("* " << descLine.strip)
          end
        }
      end

      hFile.add("*/")
    end

    # Returns the code for the header for this class
    def genHeader(cls, cfg, hFile)
      if cls.namespace.hasItems?()
        hFile.add("#ifndef __" + cls.namespace.get("_") + "_" + Utils.instance.getStyledClassName(cls.getUName()) + "_H")
        hFile.add("#define __" + cls.namespace.get("_") + "_" + Utils.instance.getStyledClassName(cls.getUName()) + "_H")
        hFile.add
      else
        hFile.add("#ifndef __" + Utils.instance.getStyledClassName(cls.getUName()) + "_H")
        hFile.add("#define __" + Utils.instance.getStyledClassName(cls.getUName()) + "_H")
        hFile.add
      end

      startNamespace(cls, hFile)

      # Do automatic static array size declairations above class def
      varArray = Array.new

      for vGrp in cls.model.groups
        CodeStructure::CodeElemModel.getVarsFor(vGrp, varArray)
      end

      classDec = "enum class " + Utils.instance.getStyledClassName(cls.getUName())

      hFile.startBlock(classDec)

      # Generate class variables
      varArray = Array.new

      for vGrp in cls.model.groups
        cls.model.getAllVarsFor(varArray)
      end

      for i in 0..(varArray.length - 1)
        var = varArray[i]
        if var.elementId == CodeElem::ELEM_VARIABLE
          hFile.add(Utils.instance.getStyledEnumName(var.name))
          if (var.defaultValue != nil)
            hFile.sameLine(" = " + var.defaultValue)
          end
          if i != varArray.length - 1
            hFile.sameLine(",")
          end
        elsif var.elementId == CodeElem::ELEM_COMMENT
          hFile.add(Utils.instance.getComment(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          hFile.add(var.formatText)
        end
      end

      hFile.endBlock(";")

      endNamespace(cls, hFile)

      hFile.separate
      hFile.add("#endif")
    end
  end
end

XCTEPlugin::registerPlugin(XCTECpp::EnumStandard.new)
