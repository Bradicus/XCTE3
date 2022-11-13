##
# Class:: Standard
# Author:: Brad Ottoson
#

require "plugins_core/lang_csharp/utils.rb"
require "plugins_core/lang_csharp/source_renderer_csharp.rb"
require "code_elem.rb"
require "code_elem_parent.rb"
require "lang_file.rb"
require "x_c_t_e_plugin.rb"

module XCTECSharp
  class ClassStandard < XCTEPlugin
    def initialize
      @name = "standard"
      @language = "csharp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(cls.getUName())
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      codeBuilder = SourceRendererCSharp.new
      codeBuilder.lfName = Utils.instance.getStyledFileName(cls.getUName())
      codeBuilder.lfExtension = Utils.instance.getExtension("body")
      genFileContent(cls, cfg, codeBuilder)

      srcFiles << codeBuilder

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, codeBuilder)

      # Add in any dependencies required by functions
      for fun in cls.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin::findMethodPlugin("csharp", fun.name)
            if templ != nil
              templ.process_dependencies(cls, fun, cfg, codeBuilder)
            else
              puts "ERROR no plugin for function: " + fun.name + "   language: csharp"
            end
          end
        end
      end

      Utils.instance.genUses(cls.uses, codeBuilder)
      Utils.instance.genNamespaceStart(cls.namespace, codeBuilder)

      classDec = cls.model.visibility + " class " + getClassName(cls)

      for par in (0..cls.baseClasses.size)
        if par == 0 && cls.baseClasses[par] != nil
          classDec << " : " << cls.baseClasses[par].visibility << " " << cls.baseClasses[par].name
        elsif cls.baseClasses[par] != nil
          classDec << ", " << cls.baseClasses[par].visibility << " " << cls.baseClasses[par].name
        end
      end

      codeBuilder.startClass(classDec)

      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      # Generate class variables
      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          codeBuilder.add(XCTECSharp::Utils.instance.getVarDec(var))
        elsif var.elementId == CodeElem::ELEM_COMMENT
          codeBuilder.sameLine(XCTECSharp::Utils.instance.getComment(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          codeBuilder.add(var.formatText)
        end
      end

      if (cls.functions.length > 0)
        codeBuilder.add
      end

      # Generate code for functions
      Utils.instance.genFunctions(cls, codeBuilder)

      codeBuilder.endClass

      Utils.instance.genNamespaceEnd(cls.namespace, codeBuilder)
    end
  end
end

XCTEPlugin::registerPlugin(XCTECSharp::ClassStandard.new)
