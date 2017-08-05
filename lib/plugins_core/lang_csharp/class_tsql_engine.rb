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

class XCTECSharp::ClassTsqlEngine < XCTEPlugin

  def initialize

    XCTECSharp::Utils::init

    @name = "tsql_engine"
    @language = "csharp"
    @category = XCTEPlugin::CAT_CLASS
    @author = "Brad Ottoson"
  end

  def genSourceFiles(dataModel, genClass, cfg)
    srcFiles = Array.new

    genClass.name = dataModel.name + 'Engine'
    if genClass.interfaceNamespace != nil
      genClass.includes << CodeElemInclude.new(genClass.interfaceNamespace, dataModel.name + 'Interface')
    end

    codeBuilder = SourceRendererCSharp.new
    codeBuilder.lfName = genClass.name
    codeBuilder.lfExtension = XCTECSharp::Utils::getExtension('body')
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
            templ.get_dependencies(dataModel, genClass, cfg, codeBuilder)
          else
            puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
          end
        end
      end
    end

    for inc in genClass.includes
      codeBuilder.add('using ' + inc.path + ';');
    end

    if !genClass.includes.empty?
      codeBuilder.add
    end

    # Process namespace items
    if genClass.namespaceList != nil
      codeBuilder.startBlock("namespace " << genClass.namespaceList.join('.'))
      codeBuilder.add
    end

    classDec = dataModel.visibility + " class " + genClass.name

    inheritsFrom = Array.new

    for baseClass in genClass.baseClasses
      inheritsFrom << baseClass.name
    end
    if genClass.interfaceNamespace != nil
      inheritsFrom << dataModel.name + 'Interface'
    end

    for par in (0..inheritsFrom.size)
      if par == 0 && inheritsFrom[par] != nil
        classDec << " : " << inheritsFrom[par]
      elsif inheritsFrom[par] != nil
        classDec << ", " << inheritsFrom[par]
      end
    end

    codeBuilder.startClass(classDec)

    puts genClass.name + ' has function count: ' + genClass.functions.length.to_s

    # Generate code for functions
    for fun in genClass.functions
      if fun.elementId == CodeElem::ELEM_FUNCTION
        if fun.isTemplate
          templ = XCTEPlugin::findMethodPlugin("csharp", fun.name)
          if templ != nil
            templ.get_definition(dataModel, genClass, cfg, codeBuilder)
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

XCTEPlugin::registerPlugin(XCTECSharp::ClassTsqlEngine.new)