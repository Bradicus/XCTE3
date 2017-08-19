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

require 'plugins_core/lang_cpp/utils.rb'
require 'plugins_core/lang_cpp/method_empty.rb'
require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'
require 'code_elem.rb'
require 'code_elem_parent.rb'
require 'lang_file.rb'
require 'x_c_t_e_plugin.rb'

class XCTECpp::ClassStandard < XCTEPlugin
  def initialize
    @name = "standard"
    @language = "cpp"
    @category = XCTEPlugin::CAT_CLASS
  end
  
  def genSourceFiles(dataModel, genClass, cfg)
    srcFiles = Array.new
    
    hFile = SourceRendererCpp.new
    hFile.lfName = dataModel.name
    hFile.lfExtension = XCTECpp::Utils::getExtension('header')
    genHeaderComment(dataModel, genClass, cfg, hFile)
    genHeader(dataModel, genClass, cfg, hFile)
    
    cppFile = SourceRendererCpp.new
    cppFile.lfName = dataModel.name
    cppFile.lfExtension = XCTECpp::Utils::getExtension('body')
    genHeaderComment(dataModel, genClass, cfg, cppFile)
    genBody(dataModel, genClass, cfg, cppFile)
    
    srcFiles << hFile
    srcFiles << cppFile
    
    return srcFiles
  end    
  
  def genHeaderComment(dataModel, genClass, cfg, hFile)
  
    hFile.add("/**")    
    hFile.add("* @class " + dataModel.name)
    
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
      hFile.add("#ifndef _" + genClass.namespaceList.join('_') + "_" + dataModel.name + "_H")
      hFile.add("#define _" + genClass.namespaceList.join('_') + "_" + dataModel.name + "_H")
      hFile.add
    else
      hFile.add("#ifndef _" + genClass.name + "_H")
      hFile.add("#define _" + genClass.name + "_H")
      hFile.add
    end

    ClassBase::genIncludes(dataModel, genClass, cfg, hFile)
    
    if genClass.includes.length > 0
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

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE && var.arrayElemCount > 0
        hFile.add('#define ' << XCTECpp::Utils::getSizeConst(var) << ' ' << var.arrayElemCount.to_s)
      end
    end
        
    if dataModel.hasAnArray
      hFile.add
    end
    
    classDec = "class " + dataModel.name
        
    for par in (0..genClass.baseClasses.size)
      if par == 0 && genClass.baseClasses[par] != nil
        classDec << " : " << genClass.baseClasses[par].visibility << " " << genClass.baseClasses[par].name
      elsif genClass.baseClasses[par] != nil
        classDec << ", " << genClass.baseClasses[par].visibility << " " << genClass.baseClasses[par].name
      end
    end
    
    hFile.startClass(classDec)
    
    hFile.add("public:")
  	hFile.indent
    
    # Generate function declarations
    for funItem in genClass.functions
      if funItem.elementId == CodeElem::ELEM_FUNCTION
        if funItem.isTemplate
          templ = XCTEPlugin::findMethodPlugin("cpp", funItem.name)
          if templ != nil
            if (funItem.isInline)
              templ.get_declaration_inline(dataModel, cfg, hFile)
            else
              templ.get_declaration(dataModel, cfg, hFile)
            end
          else
           # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
          end
        else  # Must be an empty function          
          templ = XCTEPlugin::findMethodPlugin("cpp", "method_empty")
          if templ != nil
            if (funItem.isInline)
              templ.get_declaration_inline(funItem, cfg, hFile)
            else
              templ.get_declaration(funItem, cfg, hFile)
            end
          else
           # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
          end         
        end
      elsif funItem.elementId == CodeElem::ELEM_COMMENT
        hFile.add(XCTECpp::Utils::getComment(funItem))
      elsif funItem.elementId == CodeElem::ELEM_FORMAT
        if (funItem.formatText == "\n")
          hFile.add
        else
          hFile.sameLine(funItem.formatText)
        end       
      end
    end
            
    # Generate class variables
    varArray = Array.new

    for vGrp in dataModel.groups
      getVarsFor(vGrp, cfg, varArray)
    end
    
    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        hFile.add(XCTECpp::Utils::getVarDec(var))
      elsif var.elementId == CodeElem::ELEM_COMMENT
        hFile.add(XCTECpp::Utils::getComment(var))
      elsif var.elementId == CodeElem::ELEM_FORMAT
        hFile.add(var.formatText)
      end
    end
	
	  hFile.unindent
        
    hFile.endClass

    # Process namespace items
    if genClass.namespaceList != nil
      genClass.namespaceList.reverse_each do |nsItem|
        hFile.endBlock("  // namespace " << nsItem)
      end
      hFile.add
    end

    hFile.add("#endif")
  end
  
  # Returns the code for the body for this class
  def genBody(dataModel, genClass, cfg, cppGen)
    cppGen.add("#include \"" << dataModel.name << ".h\"")

    # Process namespace items
    if genClass.namespaceList != nil
      for nsItem in genClass.namespaceList
        cppGen.startBlock("namespace " << nsItem)
      end
    end

    # Initialize static variables
    varArray = Array.new
    dataModel.getAllVarsFor(varArray)

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if var.isStatic
          cppGen.add(XCTECpp::Utils::getTypeName(var.vtype) << " ")
          cppGen.sameLine(dataModel.name << " :: ")
          cppGen.sameLine(var.name)
                    
          if var.arrayElemCount.to_i > 0 # This is an array
            cppGen.sameLine("[" + XCTECpp::Utils::getSizeConst(var) << "]")
          end
                    
          cppGen.sameLine(";")
        end
      end
    end
                
    cppGen.add
        
    # Generate code for functions
    for fun in genClass.functions
      if fun.elementId == CodeElem::ELEM_FUNCTION
        if fun.isTemplate             
          templ = XCTEPlugin::findMethodPlugin("cpp", fun.name)
          
          puts "processing template for function " +fun.name
          if templ != nil
            if (!fun.isInline)
              templ.get_definition(dataModel, cfg, cppGen)
            end
          else
            #puts 'ERROR no plugin for function: ' << fun.name << '   language: cpp'
          end
        else  # Must be empty function
          templ = XCTEPlugin::findMethodPlugin("cpp", "method_empty")
          if templ != nil
            if (!fun.isInline)
              templ.get_definition(dataModel, fun, cppGen)
            end
          else
            #puts 'ERROR no plugin for function: ' << fun.name << '   language: cpp'
          end
        end
      end
    end

    # Process namespace items
    if genClass.namespaceList != nil
      genClass.namespaceList.reverse_each do |nsItem|
        cppGen.endBlock
        cppGen.sameLine(";   // namespace " << nsItem)
      end
      #cppGen.add("\n"
    end
  end

  def getVarsFor(varGroup, cfg, vArray)
    for var in varGroup.vars
      vArray << var
    end

    for grp in varGroup.groups
      getVarsFor(grp, cfg, vArray)
    end
  end
  
end

XCTEPlugin::registerPlugin(XCTECpp::ClassStandard.new)
