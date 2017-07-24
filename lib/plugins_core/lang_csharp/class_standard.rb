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

class XCTECSharp::ClassStandard < XCTEPlugin

  def initialize
  
    XCTECSharp::Utils::init
    
    @name = "standard"
    @language = "csharp"
    @category = XCTEPlugin::CAT_CLASS
    @author = "Brad Ottoson"
  end
  
  def genSourceFiles(dataModel, genClass, cfg)
    srcFiles = Array.new
  
    codeBuilder = SourceRendererCSharp.new
    codeBuilder.lfName = dataModel.name
    codeBuilder.lfExtension = XCTECSharp::Utils::getExtension('body')
    genFileContent(dataModel, genClass, cfg, codeBuilder)
    
    srcFiles << codeBuilder
    
    return srcFiles
  end
  
  # Returns the code for the content for this class
  def genFileContent(dataModel, genClass, cfg, codeBuilder)

    for inc in genClass.includes
      codeBuilder.add('using ' + inc.path + ';');
    end
    
    if !genClass.includes.empty?
      codeBuilder.add
    end

    # Process namespace items
    if genClass.namespaceList != nil
      for nsItem in genClass.namespaceList
        codeBuilder.startBlock("namespace " << nsItem)
      end
      codeBuilder.add
    end
    
    classDec = dataModel.visibility + " class " + dataModel.name
        
    for par in (0..genClass.baseClasses.size)
      if par == 0 && genClass.baseClasses[par] != nil
        classDec << " < " << genClass.baseClasses[par].visibility << " " << genClass.baseClasses[par].name
      elsif genClass.baseClasses[par] != nil
        classDec << ", " << genClass.baseClasses[par].visibility << " " << genClass.baseClasses[par].name
      end
    end
    
    codeBuilder.startClass(classDec)
        
    varArray = Array.new
    dataModel.getAllVarsFor(cfg, varArray)
    if dataModel.hasAnArray
      codeBuilder.add  # If we declared array size variables add a separator
    end
    # Generate class variables
    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        codeBuilder.add(XCTECSharp::Utils::getVarDec(var))
      elsif var.elementId == CodeElem::ELEM_COMMENT
        codeBuilder.sameLine(XCTECSharp::Utils::getComment(var))
      elsif var.elementId == CodeElem::ELEM_FORMAT
        codeBuilder.add(var.formatText)
      end
    end
    codeBuilder.add
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
      end
    end  # class  + dataModel.name
    codeBuilder.endClass

    # Process namespace items
    if genClass.namespaceList != nil
      for nsItem in genClass.namespaceList
        codeBuilder.endBlock(" // namespace " + nsItem)
      end
      codeBuilder.add
    end
  end
end

XCTEPlugin::registerPlugin(XCTECSharp::ClassStandard.new)
