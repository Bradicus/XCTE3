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
    @author = "Brad Ottoson"
  end

  def genSourceFiles(dataModel, genClass, cfg)
    srcFiles = Array.new

    genClass.name = dataModel.name + 'EngineTest'
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
    Utils.instance.genIncludes(genClass.includes, codeBuilder)

    # Process namespace items
    if genClass.namespaceList != nil
      codeBuilder.startBlock("namespace " << genClass.namespaceList.join('.'))
      codeBuilder.add
    end

    classDec = dataModel.visibility + " class " + genClass.name

    codeBuilder.startClass(classDec)

    codeBuilder.add('I' + dataModel.name + 'Engine intf;')
    codeBuilder.add(dataModel.name + ' obj = new ' + dataModel.name + '();')
    codeBuilder.add('intf = new ' + dataModel.name + 'Engine();')
    
    codeBuilder.add

    varArray = Array.new
    dataModel.getAllVarsFor(cfg, varArray)

    # Generate class variables
    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if var.vtype == 'String'
          codeBuilder.add('obj.'+ Utils.instance.getStyledVariableName(var) + ' = "Test String";')
      end
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
            templ.get_definition(dataModel, genClass, fun, cfg, codeBuilder)
          else
            #puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
          end
        end

        codeBuilder.add
      end
    end  # class  + dataModel.name
    codeBuilder.endClass

    # Process namespace items
    if genClass.namespaceList != nil
      codeBuilder.endBlock(" // namespace " + genClass.namespaceList.join('.'))
      codeBuilder.add
    end
  end
end

XCTEPlugin::registerPlugin(XCTECSharp::TestEngine.new)
