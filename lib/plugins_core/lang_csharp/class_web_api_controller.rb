##
# Class:: Standard
# Author:: Brad Ottoson
#

require 'plugins_core/lang_csharp/utils.rb'
require 'plugins_core/lang_csharp/source_renderer_csharp.rb'
require 'code_elem.rb'
require 'code_elem_parent.rb'
require 'lang_file.rb'
require 'x_c_t_e_plugin.rb'

module XCTECSharp
  class ClassWebApiController < XCTEPlugin

    def initialize
      @name = "web_api_controller"
      @language = "csharp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(dataModel)
      return Utils.instance.getStyledClassName(dataModel.name)
    end
    
    def genSourceFiles(dataModel, genClass, cfg)
      srcFiles = Array.new
    
      codeBuilder = SourceRendererCSharp.new
      codeBuilder.lfName = Utils.instance.getStyledFileName(dataModel.name)
      codeBuilder.lfExtension = Utils.instance.getExtension('body')
      genFileContent(dataModel, genClass, cfg, codeBuilder)
      
      srcFiles << codeBuilder
      
      return srcFiles
    end
    
    # Returns the code for the content for this class
    def genFileContent(dataModel, genClass, cfg, codeBuilder)

      # Add in any dependencies required by functions
      for fun in genClass.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin::findMethodPlugin("csharp", fun.name)
            if templ != nil
              templ.get_dependencies(dataModel, genClass, fun, cfg, codeBuilder)
            else
              puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
            end
          end
        end
      end

      Utils.instance.genUses(genClass.uses, codeBuilder)
      Utils.instance.genNamespaceStart(genClass.namespaceList, codeBuilder)
      
      classDec = dataModel.visibility + " class " + getClassName(dataModel)

      classDec << " < ApiController"
          
      for par in (0..genClass.baseClasses.size)
        if genClass.baseClasses[par] != nil
          classDec << ", " << genClass.baseClasses[par].visibility << " " << genClass.baseClasses[par].name
        end
      end
      
      codeBuilder.startClass(classDec)
          
      varArray = Array.new
      dataModel.getAllVarsFor(varArray)

      if (genClass.functions.length > 0)
        codeBuilder.add
      end

      # Generate code for functions
      for fun in genClass.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin::findMethodPlugin("csharp", fun.name)
            if templ != nil
              templ.get_definition(dataModel, genClass, fun, cfg, codeBuilder)
            else
              puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
            end
          else  # Must be empty function
            templ = XCTEPlugin::findMethodPlugin("csharp", "method_empty")
            if templ != nil
              templ.get_definition(dataModel, genClass, cfg, codeBuilder)
            else
              #puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
            end
          end
        end
      end  # class  + dataModel.name
      codeBuilder.endClass

      Utils.instance.genNamespaceEnd(genClass.namespaceList, codeBuilder)
    end
  end
end

XCTEPlugin::registerPlugin(XCTECSharp::ClassWebApiController.new)
