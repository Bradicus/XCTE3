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
    XCTECpp::Utils::init
    
    @name = "standard"
    @language = "cpp"
    @category = XCTEPlugin::CAT_CLASS
    @author = "Brad Ottoson"
  end
  
  def genSourceFiles(codeClass, cfg)
    srcFiles = Array.new
    
    hFile = SourceRendererCpp.new
    hFile.lfName = codeClass.name
    hFile.lfExtension = XCTECpp::Utils::getExtension('header')
    genHeaderComment(codeClass, cfg, hFile)
    genHeader(codeClass, cfg, hFile)
    
    cppFile = SourceRendererCpp.new
    cppFile.lfName = codeClass.name
    cppFile.lfExtension = XCTECpp::Utils::getExtension('body')
    genHeaderComment(codeClass, cfg, cppFile)
    genBody(codeClass, cfg, cppFile)
    
    srcFiles << hFile
    srcFiles << cppFile
    
    return srcFiles
  end    
  
  def genHeaderComment(codeClass, cfg, hFile)
  
    hFile.add("/**")    
    hFile.add("* @class " + codeClass.name)
    
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
    
    if (codeClass.description != nil)
      codeClass.description.each_line { |descLine|
        if descLine.strip.size > 0
          hFile.add("* " << descLine.strip)
        end
      }      
    end    
    
    hFile.add("*/")
  end

  # Returns the code for the header for this class
  def genHeader(codeClass, cfg, hFile)

    if (codeClass.namespaceList != nil)
      hFile.add("#ifndef _" << codeClass.namespaceList.join('_') + "_" + codeClass.name << "_H")
      hFile.add("#define _" << codeClass.namespaceList.join('_') + "_" + codeClass.name << "_H")
    else
      hFile.add("#ifndef _" << codeClass.name << "_H")
      hFile.add("#define _" << codeClass.name << "_H")
      hFile.add
    end

    
    for inc in codeClass.includes
      if inc.itype == '<'
        hFile.add("#include <" << inc.path << inc.name << '>')
      elsif inc.name.count(".") > 0
		hFile.add('#include "' << inc.path << inc.name << '"')
	  else
        hFile.add('#include "' << inc.path << inc.name << "." << XCTECpp::Utils::getExtension('header') << '"')
      end
    end
    
    if !codeClass.includes.empty?
      hFile.add
    end

    # Process namespace items
    if codeClass.namespaceList != nil
      for nsItem in codeClass.namespaceList
        hFile.startBlock("namespace " << nsItem)
      end
      hFile.add
    end

    # Do automatic static array size declairations above class def
    varArray = Array.new

    for vGrp in codeClass.groups
      CodeStructure::CodeElemClass.getVarsFor(vGrp, cfg, varArray)
    end

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE && var.arrayElemCount > 0
        hFile.add('#define ' << XCTECpp::Utils::getSizeConst(var) << ' ' << var.arrayElemCount.to_s)
      end
    end
        
    if codeClass.hasAnArray
      hFile.add
    end
    
    classDec = "class " + codeClass.name
        
    for par in (0..codeClass.baseClasses.size)      
      if par == 0 && codeClass.baseClasses[par] != nil
        classDec << " : " << codeClass.baseClasses[par].visibility << " " << codeClass.baseClasses[par].name
      elsif codeClass.baseClasses[par] != nil
        classDec << ", " << codeClass.baseClasses[par].visibility << " " << codeClass.baseClasses[par].name
      end
    end
    
    hFile.startClass(classDec)
    
    hFile.add("public:")
  	hFile.indent
    
    # Generate function declarations
    for funItem in codeClass.functionSection
      if funItem.elementId == CodeElem::ELEM_FUNCTION
        if funItem.isTemplate
          templ = XCTEPlugin::findMethodPlugin("cpp", funItem.name)
          if templ != nil
            if (funItem.isInline)
              templ.get_declaration_inline(codeClass, cfg, hFile)
            else
              templ.get_declaration(codeClass, cfg, hFile)
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

    for vGrp in codeClass.groups
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
    if codeClass.namespaceList != nil
      codeClass.namespaceList.reverse_each do |nsItem|
        hFile.endBlock("  // namespace " << nsItem)
      end
      hFile.add
    end

    hFile.add("#endif")
  end
  
  # Returns the code for the body for this class
  def genBody(codeClass, cfg, cppGen)
    cppGen.add("#include \"" << codeClass.name << ".h\"")

    # Process namespace items
    if codeClass.namespaceList != nil
      for nsItem in codeClass.namespaceList
        cppGen.startBlock("namespace " << nsItem)
      end
    end

    # Initialize static variables
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray)

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if var.isStatic
          cppGen.add(XCTECpp::Utils::getTypeName(var.vtype) << " ")
          cppGen.sameLine(codeClass.name << " :: ")
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
    for fun in codeClass.functionSection
      if fun.elementId == CodeElem::ELEM_FUNCTION
        if fun.isTemplate             
          templ = XCTEPlugin::findMethodPlugin("cpp", fun.name)
          
          puts "processing template for function " +fun.name
          if templ != nil
            if (!fun.isInline)
              templ.get_definition(codeClass, cfg, cppGen)
            end
          else
            #puts 'ERROR no plugin for function: ' << fun.name << '   language: cpp'
          end
        else  # Must be empty function
          templ = XCTEPlugin::findMethodPlugin("cpp", "method_empty")
          if templ != nil
            if (!fun.isInline)
              templ.get_definition(codeClass, fun, cppGen)
            end
          else
            #puts 'ERROR no plugin for function: ' << fun.name << '   language: cpp'
          end
        end
      end
    end

    # Process namespace items
    if codeClass.namespaceList != nil
      codeClass.namespaceList.reverse_each do |nsItem|
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
