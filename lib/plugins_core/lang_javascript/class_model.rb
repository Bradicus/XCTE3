##

# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class generates source files for "standard" classes, 
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require 'plugins_core/lang_javascript/utils.rb'
require 'plugins_core/lang_javascript/x_c_t_e_javascript.rb'
require 'code_elem.rb'
require 'code_elem_parent.rb'
require 'code_elem_model.rb'
require 'lang_file.rb'

class XCTEJavascript::ClassModel < XCTEPlugin
  def initialize
    @name = "model"
    @language = "javascript"
    @category = XCTEPlugin::CAT_CLASS
  end
  
  def genSourceFiles(codeClass, cfg)
    srcFiles = Array.new
    
    srcFile = LangFile.new
    srcFile.lfName = codeClass.name
    srcFile.lfExtension = XCTEJavascript::Utils::getExtension('body')
    srcFile.lfContents = genJavascriptFileComment(codeClass, cfg)
    srcFile.lfContents << genJavascriptFileContent(codeClass, cfg)
    
    srcFiles << srcFile
    
    return srcFiles
  end    
  
  def genJavascriptFileComment(codeClass, cfg)
    headerString = String.new
    
    headerString << "/**\n";
    headerString << "* @class " + codeClass.name + "\n";
    
    if (cfg.codeAuthor != nil)
      headerString << "* @author " + cfg.codeAuthor + "\n";
    end
        
    if cfg.codeCompany != nil && cfg.codeCompany.size > 0
      headerString << "* " + cfg.codeCompany + "\n";
    end
    
    if cfg.codeLicense != nil && cfg.codeLicense.size > 0
      headerString << "*\n* " + cfg.codeLicense + "\n";
    end
        
    headerString << "* \n";
    
    if (codeClass.description != nil)
      codeClass.description.each_line { |descLine|
        if descLine.strip.size > 0
          headerString << "* " << descLine.chomp << "\n";       
        end
      }      
    end    
    
    headerString << "*/\n\n";
        
    return(headerString);
  end

  # Returns the code for the header for this class
  def genJavascriptFileContent(codeClass, cfg)
    headerString = String.new

    for inc in codeClass.includesList
      headerString << 'import "' << inc.path << inc.name << "\";\n"
    end
            
    # https://docs.angularjs.org/tutorial/step_11
    # headerString << "angular.module('" << codeClass.getNamespaceList(cfg, '.') << "'), []).controller(" << codeClass.name << ", "
    headerString << "function getControl($scope) {\n"
    
    # Do automatic static array size declairations at top of class
    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE && var.arrayElemCount > 0
        headerString << "    public static final int " << XCTEJavascript::Utils::getSizeConst(var) << " = " << var.arrayElemCount.to_s << ";\n"
      end
    end
    
    if codeClass.hasAnArray
      headerString << "\n"  # If we declaired array size variables add a seperator
    end
            
    # Generate class variables
    headerString << "    // -- Variables --\n"
    
    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        headerString << "    " << XCTEJavascript::Utils::getVarDec(var);
      elsif var.elementId == CodeElem::ELEM_COMMENT
        headerString << "    " <<  XCTEJavascript::Utils::getComment(var)
      elsif var.elementId == CodeElem::ELEM_FORMAT
        headerString << var.formatText
      end
    end
    
    headerString << "\n"
    
    # Generate code for functions
    for fun in codeClass.functionSection
      if fun.elementId == CodeElem::ELEM_FUNCTION
        if fun.isTemplate             
          templ = XCTEPlugin::findMethodPlugin("javascript", fun.name)
          if templ != nil            
            headerString << templ.get_definition(codeClass, cfg)
          else
            #puts 'ERROR no plugin for function: ' << fun.name << '   language: java'
          end
        else  # Must be empty function
          templ = XCTEPlugin::findMethodPlugin("javascript", "method_empty")
          if templ != nil            
            headerString << templ.get_definition(fun, cfg)
          else
            #puts 'ERROR no plugin for function: ' << fun.name << '   language: java'
          end
        end
      end
    end
        
    headerString << "}\n\n";
        
    return(headerString);
  end
  
end

XCTEPlugin::registerPlugin(XCTEJavascript::ClassModel.new)
