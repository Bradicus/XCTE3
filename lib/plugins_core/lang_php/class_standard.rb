##

# 
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class generates source files for "standard" classes, 
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require 'plugins_core/lang_php/utils.rb'
require 'plugins_core/lang_php/x_c_t_e_php.rb'
require 'code_elem.rb'
require 'code_elem_parent.rb'
require 'lang_file.rb'

class XCTEPhp::ClassStandard < XCTEPlugin
  def initialize
    @name = "standard"
    @language = "php"
    @category = XCTEPlugin::CAT_CLASS
  end
  
  def genSourceFiles(codeClass, cfg)
    srcFiles = Array.new
    
    phpFile = LangFile.new
    phpFile.lfName = codeClass.name
    phpFile.lfExtension = XCTEPhp::Utils::getExtension('body')
    
    phpFile.add("<?php")
    genPhpFileComment(codeClass, cfg, phpFile)
    genPhpFileContent(codeClass, cfg, phpFile)
    phpFile.add("?>")
    
    srcFiles << phpFile
    
    return srcFiles
  end    
  
  def genPhpFileComment(codeClass, cfg, outCode)
    
    outCode.add("/**")
    outCode.add("* @class " + codeClass.name)
    
    if (cfg.codeAuthor != nil)
      outCode.add("* @author " + cfg.codeAuthor)
    end
        
    if cfg.codeCompany != nil && cfg.codeCompany.size > 0
      outCode.add("* " + cfg.codeCompany)
    end
    
    if cfg.codeLicense != nil && cfg.codeLicense.size > 0
      outCode.add("*\n* " + cfg.codeLicense)
    end
        
    outCode.add("* ")
    
    if (codeClass.description != nil)
      codeClass.description.each_line { |descLine|
        if descLine.strip.size > 0
          outCode.add("* " << descLine.chomp)    
        end
      }      
    end    
    
    outCode.add("*/")
        
    
  end

  # Returns the code for the header for this class
  def genPhpFileContent(codeClass, cfg, outCode)
    headerString = String.new
    
    outCode.add
    
    for inc in codeClass.includesList
      outCode.add('include_once("' << inc.path << inc.name << ".php\");")
    end
    
    if !codeClass.includesList.empty?
      outCode.add("")
    end
        
    if codeClass.hasAnArray
      outCode.add("")
    end
    
    outCode.add("class " << codeClass.name)
    outCode.add("{")
                
    outCode.add
    
    # Generate code for functions
    for fun in codeClass.functionSection
      if fun.elementId == CodeElem::ELEM_FUNCTION
        if fun.isTemplate             
          templ = XCTEPlugin::findMethodPlugin("php", fun.name)
          if templ != nil            
            templ.get_definition(codeClass, cfg, outCode)
          else
            #puts 'ERROR no plugin for function: ' << fun.name << '   language: java'
          end
        else  # Must be empty function
          templ = XCTEPlugin::findMethodPlugin("php", "method_empty")
          if templ != nil            
            templ.get_definition(fun, outCode)
          else
            #puts 'ERROR no plugin for function: ' << fun.name << '   language: java'
          end
        end
      end
    end
        
    outCode.add("}")
  end
  
end

XCTEPlugin::registerPlugin(XCTEPhp::ClassStandard.new)
