##
# Class:: Standard
# Author:: Brad Ottoson
#

require 'plugins_core/lang_csharp/utils.rb'
require 'plugins_core/lang_csharp/x_c_t_e_csharp.rb'
require 'plugins_core/lang_csharp/source_renderer_csharp.rb'
require 'code_elem.rb'
require 'code_elem_parent.rb'
require 'lang_file.rb'
require 'x_c_t_e_plugin.rb'

include XCTECSharp

class XCTECSharp::TestEngine < XCTEPlugin

  def initialize
    @name = "test_engine"
    @language = "csharp"
    @category = XCTEPlugin::CAT_CLASS
  end

  def genSourceFiles(dataModel, genClass, cfg)
    srcFiles = Array.new

    genClass.setName(Utils.instance.getStyledClassName(dataModel.name + ' engine test'))
    if genClass.interfaceNamespace != nil
      genClass.includes << CodeElemInclude.new(genClass.interfaceNamespace, dataModel.name + 'Interface')
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

    templ = XCTEPlugin::findMethodPlugin("csharp", 'method_test_engine')
    templ.get_dependencies(dataModel, genClass, cfg, codeBuilder)

    Utils.instance.genFunctionDependencies(dataModel, genClass, cfg, codeBuilder)
    Utils.instance.genIncludes(genClass.includes, codeBuilder)

    Utils.instance.genNamespaceStart(genClass.namespaceList, codeBuilder)

    classDec = dataModel.visibility + " class " + genClass.name

    codeBuilder.startClass(classDec)

    templ.get_definition(dataModel, genClass, cfg, codeBuilder)

    codeBuilder.endClass

    Utils.instance.genNamespaceEnd(genClass.namespaceList, codeBuilder)

  end
end

XCTEPlugin::registerPlugin(XCTECSharp::TestEngine.new)
