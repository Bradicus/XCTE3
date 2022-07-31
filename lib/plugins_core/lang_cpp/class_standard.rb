##

#
# Copyright (C) 2008 Brad Ottoson
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
  class ClassStandard < ClassBase
    def initialize
      @name = "standard"
      @language = "cpp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.model.name
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      bld = SourceRendererCpp.new
      bld.lfName = Utils.instance.getStyledFileName(cls.model.name)
      bld.lfExtension = Utils.instance.getExtension("header")
      genHeaderComment(cls, cfg, bld)
      genHeader(cls, cfg, bld)

      cppFile = SourceRendererCpp.new
      cppFile.lfName = Utils.instance.getStyledFileName(cls.model.name)
      cppFile.lfExtension = Utils.instance.getExtension("body")
      genHeaderComment(cls, cfg, cppFile)
      genBody(cls, cfg, cppFile)

      srcFiles << bld
      srcFiles << cppFile

      return srcFiles
    end

    def genHeaderComment(cls, cfg, bld)
      bld.add("/**")
      bld.add("* @class " + Utils.instance.getStyledClassName(cls.model.name))

      if (cfg.codeAuthor != nil)
        bld.add("* @author " + cfg.codeAuthor)
      end

      if cfg.codeCompany != nil && cfg.codeCompany.size > 0
        bld.add("* " + cfg.codeCompany)
      end

      if cfg.codeLicense != nil && cfg.codeLicense.size > 0
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
    def genHeader(cls, cfg, bld)
      genIfndef(cls, bld)

      # get list of includes needed by functions

      # Generate function declarations
      for funItem in cls.functions
        if funItem.elementId == CodeElem::ELEM_FUNCTION
          if funItem.isTemplate
            templ = XCTEPlugin::findMethodPlugin("cpp", funItem.name)
            if templ != nil
              templ.get_dependencies(cls, funItem, bld)
            else
              # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end
          end
        end
      end

      process_dependencies(cls, cfg, bld)

      if cls.includes.length > 0
        bld.add
      end

      # Process namespace items
      if cls.namespaceList != nil
        for nsItem in cls.namespaceList
          bld.startBlock("namespace " << nsItem)
        end
        bld.add
      end

      # Do automatic static array size declairations above class def
      varArray = Array.new

      for vGrp in cls.model.groups
        CodeStructure::CodeElemModel.getVarsFor(vGrp, varArray)
      end

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE && var.arrayElemCount > 0
          bld.add("#define " << Utils.instance.getSizeConst(var) << " " << var.arrayElemCount.to_s)
        end
      end

      if cls.model.hasAnArray
        bld.add
      end

      classDec = "class " + Utils.instance.getStyledClassName(cls.model.name)

      inheritFrom = Array.new

      for bcls in cls.baseClasses
        inheritFrom.push(bcls.visibility + " " + Utils.instance.getClassTypeName(bcls))
      end

      for icls in cls.interfaces
        inheritFrom.push(icls.visibility + " " + Utils.instance.getClassTypeName(icls))
      end

      if (inheritFrom.length > 0)
        classDec += " : " + inheritFrom.join(", ")
      end

      bld.startClass(classDec)

      bld.add("public:")
      bld.indent

      # Generate class variables
      varArray = Array.new

      for vGrp in cls.model.groups
        getVarsFor(vGrp, cfg, varArray)
      end

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          bld.add(Utils.instance.getVarDec(var))
        elsif var.elementId == CodeElem::ELEM_COMMENT
          bld.add(Utils.instance.getComment(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          bld.add(var.formatText)
        end
      end

      if (cls.functions.length > 0)
        bld.add
      end

      # Generate function declarations
      for funItem in cls.functions
        if funItem.elementId == CodeElem::ELEM_FUNCTION
          if funItem.isTemplate
            templ = XCTEPlugin::findMethodPlugin("cpp", funItem.name)
            if templ != nil
              if (funItem.isInline)
                templ.get_declaration_inline(cls, funItem, bld)
              else
                templ.get_declaration(cls, funItem, bld)
              end
            else
              # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end
          else # Must be an empty function
            templ = XCTEPlugin::findMethodPlugin("cpp", "method_empty")
            if templ != nil
              if (funItem.isInline)
                templ.get_declaration_inline(cls, funItem, bld)
              else
                templ.get_declaration(cls, funItem, bld)
              end
            else
              # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end
          end
        elsif funItem.elementId == CodeElem::ELEM_COMMENT
          bld.add(Utils.instance.getComment(funItem))
        elsif funItem.elementId == CodeElem::ELEM_FORMAT
          if (funItem.formatText == "\n")
            bld.add
          else
            bld.sameLine(funItem.formatText)
          end
        end
      end

      bld.unindent

      bld.add("//+XCTE Custom Code Area")
      bld.add
      bld.add("//-XCTE Custom Code Area")

      bld.endClass

      # Process namespace items
      if cls.namespaceList != nil
        cls.namespaceList.reverse_each do |nsItem|
          bld.endBlock("  // namespace " << nsItem)
        end
        bld.add
      end

      bld.add("#endif")
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
            elsif var.defaultValue != nil
              cppGen.sameLine(" = " + var.defaultValue)
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

      cppGen.add("//+XCTE Custom Code Area")
      cppGen.add
      cppGen.add("//-XCTE Custom Code Area")

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

XCTEPlugin::registerPlugin(XCTECpp::ClassStandard.new)
