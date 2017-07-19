##
# @author Brad Ottoson
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

class XCTEJavascript::ClassKendoDatasource < XCTEPlugin
  def initialize
    XCTEJavascript::Utils::init
    
    @name = "kendo_datasource"
    @language = "javascript"
    @category = XCTEPlugin::CAT_CLASS
    @author = "Brad Ottoson"
  end
  
  def genSourceFiles(codeClass, cfg)
    srcFiles = Array.new
    
    srcFile = SourceRendererJavascript.new
    srcFile.lfName = codeClass.name
    srcFile.lfExtension = XCTEJavascript::Utils::getExtension('body')
    
    genJavascriptFileComment(codeClass, cfg, srcFile)
    genJavascriptFileContent(codeClass, cfg, srcFile)
    
    srcFiles << srcFile
    
    return srcFiles
  end    
  
  def genJavascriptFileComment(codeClass, cfg, outCode)    
    
    outCode.add "/**"
        
    if cfg.codeCompany != nil && cfg.codeCompany.size > 0
      outCode.add "* " + cfg.codeCompany + ""
    end
    
    if cfg.codeLicense != nil && cfg.codeLicense.size > 0
      outCode.add "** " + cfg.codeLicense + ""
    end
        
    outCode.add "* ";
    
    if (codeClass.description != nil)
      codeClass.description.each_line { |descLine|
        if descLine.strip.size > 0
          outCode.add "* " + descLine.chomp
        end
      }      
    end    
    
    outCode.add "*/"
  end

  # Returns the code for the header for this class
  def genJavascriptFileContent(codeClass, cfg, outCode)
    headerString = String.new

    for inc in codeClass.includesList
      outCode.add 'import "' + inc.path + inc.name + "\";"
    end
            
    outCode.startBlock("function gen" + codeClass.name + "DataSource($scope)")
        
    outCode.add("return(")
    outCode.indent
    outCode.startBlock("new kendo.data.DataSource(")
    outCode.startBlock("transport:")
    outCode.startBlock("read:")
    outCode.add('url: "/data/' + codeClass.name.downcase + '",')
    outCode.add('dataType: "json"')
    outCode.endBlock
    outCode.startBlock(', parameterMap: function(data, type) ')                        
    outCode.add('var params = {};')
    outCode.add('params.username = rc_credentials.username;')
    outCode.add('return params;')
    outCode.endBlock
    outCode.endBlock
    outCode.startBlock(', schema:')
    outCode.add('data: "data",')
    outCode.add('total: "data.length",')
    outCode.startBlock('model:')
    outCode.add('id: "id",')
    outCode.startBlock('fields: ')
    
    # Do automatic static array size declairations at top of class
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);
            
    # Generate class variables
    outCode.add "    // -- Fields --"
    
    first = true
    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        codeLine = '"' + var.name + '": {type: "' + XCTEJavascript::Utils::getTypeName(var.vtype) + '"}'
      elsif var.elementId == CodeElem::ELEM_COMMENT
        codeLine = XCTEJavascript::Utils::getComment(var)
      elsif var.elementId == CodeElem::ELEM_FORMAT
        codeLine = var.formatText
      end      
      
      if (first == false)
        codeLine  = ", " + codeLine
        outCode.add(codeLine)
      elsif (var.elementId == CodeElem::ELEM_VARIABLE)          
        first = false
      end
    end
    
    outCode.endBlock
    outCode.endBlock
    outCode.endBlock
    outCode.add            
    outCode.add('pageSize: 20')
    outCode.endBlock
    outCode.add(')')
    outCode.unindent
    outCode.add(');')
        
    outCode.endBlock
  end
end

XCTEPlugin::registerPlugin(XCTEJavascript::ClassKendoDatasource.new)
