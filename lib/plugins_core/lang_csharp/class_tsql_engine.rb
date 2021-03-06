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
  class ClassTsqlEngine < XCTEPlugin

    def initialize
      @name = "tsql_engine"
      @language = "csharp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(dataModel, genClass)
      return Utils.instance.getStyledClassName(dataModel.name + ' engine')
    end

    def genSourceFiles(dataModel, genClass, cfg)
      srcFiles = Array.new

      genClass.setName(getClassName(dataModel, genClass))

      if genClass.interfaceNamespace != nil
        genClass.addUse(genClass.interfaceNamespace, 'I' + dataModel.name + 'Engine')
      end

      codeBuilder = SourceRendererCSharp.new
      codeBuilder.lfName = genClass.name
      codeBuilder.lfExtension = Utils.instance.getExtension('body')
      genFileContent(dataModel, genClass, cfg, codeBuilder)

      srcFiles << codeBuilder

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(dataModel, genClass, cfg, codeBuilder)

      Utils.instance.genFunctionDependencies(dataModel, genClass, cfg, codeBuilder)
      Utils.instance.genUses(genClass.uses, codeBuilder)
      Utils.instance.genNamespaceStart(genClass.namespaceList, codeBuilder)

      classDec = dataModel.visibility + " class " + genClass.name

      inheritsFrom = Array.new

      for baseClass in genClass.baseClasses
        inheritsFrom << baseClass.name
      end
      if genClass.interfaceNamespace != nil
        inheritsFrom << Utils.instance.getStyledClassName('i ' + dataModel.name + ' engine')
      end

      for par in (0..inheritsFrom.size)
        if par == 0 && inheritsFrom[par] != nil
          classDec << " : " << inheritsFrom[par]
        elsif inheritsFrom[par] != nil
          classDec << ", " << inheritsFrom[par]
        end
      end

      codeBuilder.startClass(classDec)

      Utils.instance.genFunctions(dataModel, genClass, codeBuilder)

      codeBuilder.endClass

      Utils.instance.genNamespaceEnd(genClass.namespaceList, codeBuilder)
    end
  end
end

XCTEPlugin::registerPlugin(XCTECSharp::ClassTsqlEngine.new)
