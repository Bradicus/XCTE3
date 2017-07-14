##
# Class:: Interface
# Author:: Brad Ottoson
#

require 'plugins_core/lang_csharp/utils.rb'
require 'plugins_core/lang_csharp/x_c_t_e_csharp.rb'
require 'plugins_core/lang_csharp/source_renderer_csharp.rb'
require 'code_elem.rb'
require 'code_elem_parent.rb'
require 'lang_file.rb'
require 'x_c_t_e_plugin.rb'

class XCTECSharp::ClassInterface < XCTEPlugin

  def initialize
  
    XCTECSharp::Utils::init
    
    @name = "interface"
    @language = "csharp"
    @category = XCTEPlugin::CAT_CLASS
    @author = "Brad Ottoson"
  end
  
  def genSourceFiles(codeClass, cfg)
    srcFiles = Array.new

    codeClass.name += "Interface"
  
    codeGen = SourceRendererCSharp.new
    codeGen.lfName = codeClass.name
    codeGen.lfExtension = XCTECSharp::Utils::getExtension('body')
    genFileContent(codeClass, cfg, codeGen)
    
    srcFiles << codeGen
    
    return srcFiles
  end
  
  # Returns the code for the content for this class
  def genFileContent(codeClass, cfg, codeGen)
  
    for inc in codeClass.includes
        codeGen.add(' "' << inc.path << inc.name << "." << XCTECpp::Utils::getExtension('header') << '"')
    end
    
    if !codeClass.includes.empty?
      codeGen.add
    end

    # Process namespace items
    if codeClass.namespaceList != nil
      for nsItem in codeClass.namespaceList
        codeGen.startBlock("namespace " << nsItem)
      end
      codeGen.add
    end
    
    classDec = codeClass.visibility + " interface " + codeClass.name
        
    for par in (0..codeClass.baseClasses.size)      
      if par == 0 && codeClass.baseClasses[par] != nil
        classDec << " < " << codeClass.baseClasses[par].visibility << " " << codeClass.baseClasses[par].name
      elsif codeClass.baseClasses[par] != nil
        classDec << ", " << codeClass.baseClasses[par].visibility << " " << codeClass.baseClasses[par].name
      end
    end
    
    codeGen.startClass(classDec)
        
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);
    if codeClass.hasAnArray
      codeGen.add  # If we declaired array size variables add a seperator
    end
    
    # Generate code for functions
    for fun in codeClass.functionSection
      if fun.elementId == CodeElem::ELEM_FUNCTION
        if fun.isTemplate
          templ = XCTEPlugin::findMethodPlugin("csharp", fun.name)
          if templ != nil
            codeGen.add(templ.get_declairation(codeClass, cfg))
          else
          #puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
          end
        else  # Must be empty function
          templ = XCTEPlugin::findMethodPlugin("csharp", "method_empty")
          if templ != nil
            codeGen.add(templ.get_declairation(fun, cfg))
          else
            #puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
          end
        end
      end
    end  # class  + codeClass.name
    codeGen.endClass
  end
end

XCTEPlugin::registerPlugin(XCTECSharp::ClassInterface.new)
