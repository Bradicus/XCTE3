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

require 'plugins_core/lang_csharp/utils.rb'
require 'code_elem.rb'
require 'code_elem_parent.rb'
require 'lang_file.rb'
require 'x_c_t_e_plugin.rb'

module XCTECSharp
  class EnumStandard < XCTEPlugin
    def initialize
      @name = "enum"
      @language = "csharp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(dataModel, genClass)
      return dataModel.name
    end    
    
    def genSourceFiles(dataModel, genClass, cfg)
      srcFiles = Array.new

      genClass.setName(getUnformattedClassName(dataModel, genClass)) 
      
      hFile = SourceRendererCpp.new
      hFile.lfName = Utils.instance.getStyledFileName(dataModel.name)
      hFile.lfExtension = Utils.instance.getExtension('header')
      genHeaderComment(dataModel, genClass, cfg, hFile)
      getBody(dataModel, genClass, cfg, hFile)
      
      srcFiles << hFile
      
      return srcFiles
    end  

    def genHeaderComment(dataModel, genClass, cfg, hFile)
    
      hFile.add("/**")    
      hFile.add("* @enum " + dataModel.name)
      
      if (cfg.codeAuthor != nil)
        hFile.add("* @author " + cfg.codeAuthor)
      end
          
      if cfg.codeCompany != nil && cfg.codeCompany.size > 0
        hFile.add("* " + cfg.codeCompany)
      end
      
      if cfg.codeLicense != nil && cfg.codeLicense.size > 0
        hFile.add("*")
        hFile.add("* " + cfg.codeLicense)
      end
          
      hFile.add("* ")
      
      if (dataModel.description != nil)
        dataModel.description.each_line { |descLine|
          if descLine.strip.size > 0
            hFile.add("* " << descLine.strip)
          end
        }      
      end    
      
      hFile.add("*/")
    end

    # Returns the code for the header for this class
    def getBody(dataModel, genClass, cfg, hFile)

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
      
      classDec = dataModel.visibility + " enum  " + getClassName(dataModel)
          
      hFile.startBlock(classDec)
                  
      # Generate class variables
      varArray = Array.new

      for vGrp in dataModel.groups
        dataModel.getAllVarsFor(varArray)
      end

      for i in 0..(varArray.length - 1)
        var = varArray[i];
        if var.elementId == CodeElem::ELEM_VARIABLE
          hFile.add(Utils.instance.getStyledEnumName(var.name)          )
          if (var.defaultValue != nil)
            hFile.sameLine(" = " + var.defaultValue)
          end
          if i != varArray.length - 1
            hFile.sameLine(",")
          end
        elsif var.elementId == CodeElem::ELEM_COMMENT
          hFile.add(Utils.instance.getComment(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          hFile.add(var.formatText)
        end
      end
      
      hFile.endBlock(";")

      # Process namespace items
      if genClass.namespaceList != nil
        genClass.namespaceList.reverse_each do |nsItem|
          hFile.endBlock("  // namespace " << nsItem)
        end
        hFile.add
      end

      hFile.add("#endif")
    end
  end
end

XCTEPlugin::registerPlugin(XCTECSharp::EnumStandard.new)
