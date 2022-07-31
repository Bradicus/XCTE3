##

#
# Copyright (C) 2008 Brad Ottoson
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
  class ClassPugiXmlEngine < ClassBase
    def initialize
      @name = "pugixml_engine"
      @language = "cpp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.model.name + " pugi xml engine"
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      hFile = SourceRendererCpp.new
      hFile.lfName = Utils.instance.getStyledFileName(cls.model.name + "PugiXmlEngine")
      hFile.lfExtension = Utils.instance.getExtension("header")
      genHeaderComment(cls, cfg, hFile)
      genHeader(cls, cfg, hFile)

      cppFile = SourceRendererCpp.new
      cppFile.lfName = Utils.instance.getStyledFileName(cls.model.name + "PugiXmlEngine")
      cppFile.lfExtension = Utils.instance.getExtension("body")
      genHeaderComment(cls, cfg, cppFile)
      genBody(cls, cfg, cppFile)

      srcFiles << hFile
      srcFiles << cppFile

      return srcFiles
    end

    def genHeaderComment(cls, cfg, hFile)
      hFile.add("/**")
      hFile.add("* @class " + getClassName(cls))

      if (cfg.codeAuthor != nil)
        hFile.add("* @author " + cfg.codeAuthor)
      end

      if cfg.codeCompany != nil && cfg.codeCompany.size > 0
        hFile.add("* " + cfg.codeCompany)
      end

      if cfg.codeLicense != nil && cfg.codeLicense.size > 0
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
      genIfndef(cls, hFile)

      # get list of includes needed by functions

      # Generate function declarations
      for funItem in cls.functions
        if funItem.elementId == CodeElem::ELEM_FUNCTION
          if funItem.isTemplate
            templ = XCTEPlugin::findMethodPlugin("cpp", funItem.name)
            if templ != nil
              templ.get_dependencies(cls, funItem, hFile)
            else
              # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end
          end
        end
      end

      process_dependencies(cls, cfg, bld)

      if cls.includes.length > 0
        hFile.add
      end

      # Process namespace items
      if cls.namespaceList != nil
        for nsItem in cls.namespaceList
          hFile.startBlock("namespace " << nsItem)
        end
        hFile.add
      end

      # Do automatic static array size declairations above class def
      varArray = Array.new

      for vGrp in cls.model.groups
        CodeStructure::CodeElemModel.getVarsFor(vGrp, varArray)
      end

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE && var.arrayElemCount > 0
          hFile.add("#define " << Utils.instance.getSizeConst(var) << " " << var.arrayElemCount.to_s)
        end
      end

      if cls.model.hasAnArray
        hFile.add
      end

      classDec = "class " + cls.name

      for par in (0..cls.baseClasses.size)
        nameSp = ""
        if par == 0 && cls.baseClasses[par] != nil
          classDec << " : "
        elsif cls.baseClasses[par] != nil
          classDec << ", "
        end

        if cls.baseClasses[par] != nil
          if cls.baseClasses[par].namespaceList != nil && cls.baseClasses[par].namespaceList.size > 0
            nameSp = cls.baseClasses[par].namespaceList.join("::") + "::"
          end

          classDec << cls.baseClasses[par].visibility << " " << nameSp << Utils.instance.getStyledClassName(cls.baseClasses[par].name)
        end
      end

      hFile.startClass(classDec)

      hFile.add("public:")
      hFile.indent

      # Generate class variables
      varArray = Array.new

      for vGrp in cls.model.groups
        getVarsFor(vGrp, cfg, varArray)
      end

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          hFile.add(Utils.instance.getVarDec(var))
        elsif var.elementId == CodeElem::ELEM_COMMENT
          hFile.add(Utils.instance.getComment(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          hFile.add(var.formatText)
        end
      end

      if (cls.functions.length > 0)
        hFile.add
      end

      # Generate function declarations
      for funItem in cls.functions
        if funItem.elementId == CodeElem::ELEM_FUNCTION
          if funItem.isTemplate
            templ = XCTEPlugin::findMethodPlugin("cpp", funItem.name)
            if templ != nil
              if (funItem.isInline)
                templ.get_declaration_inline(cls, funItem, hFile)
              else
                templ.get_declaration(cls, funItem, hFile)
              end
            else
              # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end
          else # Must be an empty function
            templ = XCTEPlugin::findMethodPlugin("cpp", "method_empty")
            if templ != nil
              if (funItem.isInline)
                templ.get_declaration_inline(cls, funItem, hFile)
              else
                templ.get_declaration(cls, funItem, hFile)
              end
            else
              # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end
          end
        elsif funItem.elementId == CodeElem::ELEM_COMMENT
          hFile.add(Utils.instance.getComment(funItem))
        elsif funItem.elementId == CodeElem::ELEM_FORMAT
          if (funItem.formatText == "\n")
            hFile.add
          else
            hFile.sameLine(funItem.formatText)
          end
        end
      end

      hFile.unindent

      hFile.endClass

      # Process namespace items
      if cls.namespaceList != nil
        cls.namespaceList.reverse_each do |nsItem|
          hFile.endBlock("  // namespace " << nsItem)
        end
        hFile.add
      end

      hFile.add("#endif")
    end

    # Returns the code for the body for this class
    def genBody(cls, cfg, cppGen)
      cppGen.add("#include \"" << Utils.instance.getStyledClassName(cls.model.name) << ".h\"")
      cppGen.add

      # Process namespace items
      if cls.namespaceList != nil
        for nsItem in cls.namespaceList
          cppGen.startBlock("namespace " << nsItem)
        end
      end

      # Initialize static variables
      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          if var.isStatic
            cppGen.add(Utils.instance.getTypeName(var) << " ")
            cppGen.sameLine(Utils.instance.getStyledClassName(cls.model.name) << " :: ")
            cppGen.sameLine(Utils.instance.getStyledVariableName(var))

            if var.arrayElemCount.to_i > 0 # This is an array
              cppGen.sameLine("[" + Utils.instance.getSizeConst(var) << "]")
            end

            cppGen.sameLine(";")
          end
        end
      end

      cppGen.add

      # Generate code for functions
      for fun in cls.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin::findMethodPlugin("cpp", fun.name)

            puts "processing template for function " + fun.name
            if templ != nil
              if (!fun.isInline)
                templ.get_definition(cls, fun, cppGen)
              end
            else
              #puts 'ERROR no plugin for function: ' << fun.name << '   language: cpp'
            end
          else # Must be empty function
            templ = XCTEPlugin::findMethodPlugin("cpp", "method_empty")
            if templ != nil
              if (!fun.isInline)
                templ.get_definition(cls, fun, cppGen)
              end
            else
              #puts 'ERROR no plugin for function: ' << fun.name << '   language: cpp'
            end
          end
        end
      end

      # Process namespace items
      if cls.namespaceList != nil
        cls.namespaceList.reverse_each do |nsItem|
          cppGen.endBlock
          cppGen.sameLine(";   // namespace " << nsItem)
        end
        #cppGen.add("\n"
      end
    end

    def getVarsFor(varGroup, cfg, vArray)
      for var in varGroup.vars
        vArray << var
      end

      for grp in varGroup.groups
        getVarsFor(grp, cfg, vArray)
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTECpp::ClassPugiXmlEngine.new)
