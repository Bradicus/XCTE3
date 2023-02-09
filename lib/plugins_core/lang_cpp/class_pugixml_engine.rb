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
require "log"

module XCTECpp
  class ClassPugiXmlEngine < ClassBase
    def initialize
      @name = "pugixml_engine"
      @language = "cpp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " pugi xml engine"
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      hFile = SourceRendererCpp.new
      hFile.lfName = Utils.instance.getStyledFileName(cls.getUName() + "PugiXmlEngine")
      hFile.lfExtension = Utils.instance.getExtension("header")
      genHeaderComment(cls, hFile)
      genHeader(cls, hFile)

      cppFile = SourceRendererCpp.new
      cppFile.lfName = Utils.instance.getStyledFileName(cls.getUName() + "PugiXmlEngine")
      cppFile.lfExtension = Utils.instance.getExtension("body")
      genHeaderComment(cls, cppFile)
      genBody(cls, cppFile)

      srcFiles << hFile
      srcFiles << cppFile

      return srcFiles
    end

    def genHeaderComment(cls, hFile)
      hFile.add("/**")
      hFile.add("* @class " + getClassName(cls))

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
    def genHeader(cls, hFile)
      render_ifndef(cls, hFile)

      # get list of includes needed by functions

      # Generate function declarations
      for funItem in cls.functions
        if funItem.elementId == CodeElem::ELEM_FUNCTION
          if funItem.isTemplate
            templ = XCTEPlugin::findMethodPlugin("cpp", funItem.name)
            if templ != nil
              templ.process_dependencies(cls, funItem, hFile)
            else
              # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end
          end
        end
      end

      process_dependencies(cls, bld)

      if cls.includes.length > 0
        hFile.add
      end

      # Process namespace items
      if cls.namespace.hasItems?()
        for nsItem in cls.namespace.nsList
          hFile.startBlock("namespace " << nsItem)
        end
        hFile.add
      end

      # Do automatic static array size declairations above class def

      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.arrayElemCount > 0
          hFile.add("#define " << Utils.instance.getSizeConst(var) << " " << var.arrayElemCount.to_s)
        end
      }))

      if Utils.instance.hasAnArray(cls)
        hFile.separate
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
          if cls.baseClasses[par].namespace.hasItems?() && cls.baseClasses[par].namespace.nsList.size > 0
            nameSp = cls.baseClasses[par].namespace.get("::") + "::"
          end

          classDec << cls.baseClasses[par].visibility << " " << nameSp << Utils.instance.getStyledClassName(cls.baseClasses[par].name)
        end
      end

      hFile.startClass(classDec)

      hFile.add("public:")
      hFile.indent

      # Generate class variables

      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.arrayElemCount > 0
          hFile.add(Utils.instance.getVarDec(var))
        end
      }))

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

      render_namespace_end(cls, hFile)

      hFile.separate
      hFile.add("#endif")
    end

    # Returns the code for the body for this class
    def genBody(cls, cppGen)
      cppGen.add("#include \"" << Utils.instance.getStyledClassName(cls.getUName()) << ".h\"")
      cppGen.add

      render_namespace_start(cls, cppGen)

      # Initialize static variables
      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          if var.isStatic
            cppGen.add(Utils.instance.getTypeName(var) << " ")
            cppGen.sameLine(Utils.instance.getStyledClassName(cls.getUName()) << " :: ")
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

            Log.debug("processing template for function " + fun.name)
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

      render_namespace_end(cls, cppGen)
    end
  end
end

XCTEPlugin::registerPlugin(XCTECpp::ClassPugiXmlEngine.new)
