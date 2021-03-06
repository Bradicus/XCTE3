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
  class ClassStandard < ClassBase
    def initialize
      @name = "standard"
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
      
      cppFile = SourceRendererCpp.new
      cppFile.lfName = Utils.instance.getStyledFileName(dataModel.name)
      cppFile.lfExtension = Utils.instance.getExtension('body')
      genHeaderComment(dataModel, genClass, cfg, cppFile)
      genBody(dataModel, genClass, cfg, cppFile)
      
      srcFiles << hFile
      srcFiles << cppFile
      
      return srcFiles
    end  

    def genHeaderComment(dataModel, genClass, cfg, hFile)
    
      hFile.add("/**")    
      hFile.add("* @class " + Utils.instance.getStyledClassName(dataModel.name))
      
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

      genIfndef(dataModel, genClass, hFile)

      # get list of includes needed by functions
      
      # Generate function declarations
      for funItem in genClass.functions
        if funItem.elementId == CodeElem::ELEM_FUNCTION
          if funItem.isTemplate
            templ = XCTEPlugin::findMethodPlugin("cpp", funItem.name)
            if templ != nil
              templ.get_dependencies(dataModel, genClass, funItem, hFile)
            else
            # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end
          end
        end
      end

      genIncludes(dataModel, genClass, cfg, hFile)
      
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
          hFile.add('#define ' << Utils.instance.getSizeConst(var) << ' ' << var.arrayElemCount.to_s)
        end
      end
          
      if dataModel.hasAnArray
        hFile.add
      end
      
      classDec = "class " + Utils.instance.getStyledClassName(dataModel.name)
          
      for par in (0..genClass.baseClasses.size)
        nameSp = ""
        if par == 0 && genClass.baseClasses[par] != nil
          classDec << " : "
        elsif genClass.baseClasses[par] != nil
          classDec << ", "
        end

        if genClass.baseClasses[par] != nil
          if genClass.baseClasses[par].namespaceList != nil && genClass.baseClasses[par].namespaceList.size > 0 &&
             genClass.baseClasses[par].namespaceList.join('.') != genClass.namespaceList.join('.')
            nameSp = genClass.baseClasses[par].namespaceList.join("::") + "::"
          end

          classDec << genClass.baseClasses[par].visibility << " " << nameSp << Utils.instance.getStyledClassName(genClass.baseClasses[par].name)
        end
      end
      
      hFile.startClass(classDec)
       
      hFile.add("public:")
      hFile.indent
            
      # Generate class variables
      varArray = Array.new

      for vGrp in dataModel.groups
      getVarsFor(vGrp, cfg, varArray)
      end

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          hFile.add(Utils.instance.getVarDec(var))
        elsif var.elementId == CodeElem::ELEM_COMMENT
          hFile.add(Utils.instance.getComment(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          hFile.add(var.formatText)
        end
      end

      if (genClass.functions.length > 0)
        hFile.add
      end
      
      # Generate function declarations
      for funItem in genClass.functions
        if funItem.elementId == CodeElem::ELEM_FUNCTION
          if funItem.isTemplate
            templ = XCTEPlugin::findMethodPlugin("cpp", funItem.name)
            if templ != nil
              if (funItem.isInline)
                templ.get_declaration_inline(dataModel, genClass, funItem, hFile)
              else
                templ.get_declaration(dataModel, genClass, funItem, hFile)
              end
            else
            # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end
          else  # Must be an empty function          
            templ = XCTEPlugin::findMethodPlugin("cpp", "method_empty")
            if templ != nil
              if (funItem.isInline)
                templ.get_declaration_inline(dataModel, genClass, funItem, hFile)
              else
                templ.get_declaration(dataModel, genClass, funItem, hFile)
              end
            else
            # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end         
          end
        elsif funItem.elementId == CodeElem::ELEM_COMMENT
          hFile.add(Utils.instance.getComment(funItem))
        elsif funItem.elementId == CodeElem::ELEM_FORMAT
          if (funItem.formatText == "\n")
            hFile.add
          else
            hFile.sameLine(funItem.formatText)
          end       
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
      cppGen.add("#include \"" << Utils.instance.getStyledClassName(dataModel.name) << ".h\"")
      cppGen.add

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
            cppGen.add(Utils.instance.getTypeName(var) << " ")
            cppGen.sameLine(Utils.instance.getStyledClassName(dataModel.name) << " :: ")
            cppGen.sameLine(Utils.instance.getStyledVariableName(var))
                      
            if var.arrayElemCount.to_i > 0 # This is an array
              cppGen.sameLine("[" + Utils.instance.getSizeConst(var) << "]")
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
                templ.get_definition(dataModel, genClass, fun, cppGen)
              end
            else
              #puts 'ERROR no plugin for function: ' << fun.name << '   language: cpp'
            end
          else  # Must be empty function
            templ = XCTEPlugin::findMethodPlugin("cpp", "method_empty")
            if templ != nil
              if (!fun.isInline)
                templ.get_definition(dataModel, genClass, fun, cppGen)
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
end

XCTEPlugin::registerPlugin(XCTECpp::ClassStandard.new)
