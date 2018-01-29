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

require 'plugins_core/lang_cpp/utils.rb'
require 'plugins_core/lang_cpp/method_empty.rb'
require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'
require 'code_elem.rb'
require 'code_elem_parent.rb'
require 'lang_file.rb'
require 'x_c_t_e_plugin.rb'

module XCTECpp
  class EnumStandard < ClassBase
    def initialize
      @name = "enum"
      @language = "cpp"
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
      genHeader(dataModel, genClass, cfg, hFile)
      
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
    def genHeader(dataModel, genClass, cfg, hFile)

      if (genClass.namespaceList != nil)
        hFile.add("#ifndef _" + genClass.namespaceList.join('_') + "_" + Utils.instance.getStyledClassName(dataModel.name) + "_H")
        hFile.add("#define _" + genClass.namespaceList.join('_') + "_" + Utils.instance.getStyledClassName(dataModel.name) + "_H")
        hFile.add
      else
        hFile.add("#ifndef _" + Utils.instance.getStyledClassName(dataModel.name) + "_H")
        hFile.add("#define _" + Utils.instance.getStyledClassName(dataModel.name) + "_H")
        hFile.add
      end

      # Process namespace items
      if genClass.namespaceList != nil
        for nsItem in genClass.namespaceList
          hFile.startBlock("namespace " << nsItem)
        end
        hFile.add
      end

      # Do automatic static array size declairations above class def
      varArray = Array.new

      for vGrp in dataModel.groups
        CodeStructure::CodeElemModel.getVarsFor(vGrp, varArray)
      end

      classDec = "enum class " + Utils.instance.getStyledClassName(dataModel.name)
      
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

XCTEPlugin::registerPlugin(XCTECpp::EnumStandard.new)
