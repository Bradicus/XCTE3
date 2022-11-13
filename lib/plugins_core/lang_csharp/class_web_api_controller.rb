##
# Class:: Standard
# Author:: Brad Ottoson
#

require "plugins_core/lang_csharp/utils.rb"
require "plugins_core/lang_csharp/source_renderer_csharp.rb"
require "code_elem.rb"
require "code_elem_use.rb"
require "code_elem_namespace.rb"
require "code_elem_parent.rb"
require "lang_file.rb"
require "x_c_t_e_plugin.rb"

module XCTECSharp
  class ClassWebApiController < XCTEPlugin
    def initialize
      @name = "web_api_controller"
      @language = "csharp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(cls.getUName())
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      codeBuilder = SourceRendererCSharp.new
      codeBuilder.lfName = Utils.instance.getStyledFileName(cls.getUName() + "Controller")
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

      cls.uses.push(CodeElemUse.new(CodeStructure::CodeElemNamespace.new("System.Data.SqlClient")))
      cls.uses.push(CodeElemUse.new(CodeStructure::CodeElemNamespace.new("System.Data.SqlClient")))

      Utils.instance.genUses(cls.uses, codeBuilder)
      Utils.instance.genNamespaceStart(cls.namespace, codeBuilder)

      classDec = cls.model.visibility + " class " + getClassName(cls) + "Controller"

      classDec << " : ApiController"

      for par in (0..cls.baseClasses.size)
        if cls.baseClasses[par] != nil
          classDec << ", " << cls.baseClasses[par].visibility << " " << cls.baseClasses[par].name
        end
      end

      codeBuilder.startClass(classDec)

      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      if (cls.functions.length > 0)
        codeBuilder.add
      end

      # Generate code for functions
      for fun in cls.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin::findMethodPlugin("csharp", fun.name)
            if templ != nil
              templ.get_definition(cls, fun, cfg, codeBuilder)
            else
              puts "ERROR no plugin for function: " + fun.name + "   language: csharp"
            end
          else # Must be empty function
            templ = XCTEPlugin::findMethodPlugin("csharp", "method_empty")
            if templ != nil
              templ.get_definition(cls, cfg, codeBuilder)
            else
              #puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
            end
          end
        end
      end  # class  + cls.getUName()
      codeBuilder.endClass

      Utils.instance.genNamespaceEnd(cls.namespace, codeBuilder)
    end
  end
end

XCTEPlugin::registerPlugin(XCTECSharp::ClassWebApiController.new)
