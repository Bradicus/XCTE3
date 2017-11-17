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
  class ClassStandard < XCTEPlugin

    def initialize
      @name = "standard"
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
          
      for par in (0..genClass.baseClasses.size)
        if par == 0 && genClass.baseClasses[par] != nil
          classDec << " < " << genClass.baseClasses[par].visibility << " " << genClass.baseClasses[par].name
        elsif genClass.baseClasses[par] != nil
          classDec << ", " << genClass.baseClasses[par].visibility << " " << genClass.baseClasses[par].name
        end
      end
      
      codeBuilder.startClass(classDec)

      if genClass.dontModifyCode
        codeBuilder.add("#region DON'T MODYFY THIS CLASS, IT WILL BE OVERWRITTEN BY GENERATOR")
      end
          
      varArray = Array.new
      dataModel.getAllVarsFor(varArray)

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

      if (genClass.functions.length > 0)
        codeBuilder.add
      end

      # Generate code for functions
      Utils.instance.genFunctions(dataModel, genClass, codeBuilder)
      
      
      if genClass.dontModifyCode
        codeBuilder.add("#endregion")
      end

      codeBuilder.endClass

      Utils.instance.genNamespaceEnd(genClass.namespaceList, codeBuilder)
    end
  end
end

XCTEPlugin::registerPlugin(XCTECSharp::ClassStandard.new)
