##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class contains the language profile for CSharp and utility fuctions
# used by various plugins
 
require 'lang_profile.rb'
require 'code_name_styling.rb'
require 'utils_base.rb'
require 'singleton'

module XCTECSharp
  class Utils < UtilsBase
    include Singleton

    def initialize
      super('csharp')
    end
    
    # Get a parameter declaration for a method parameter
    def getParamDec(var)
      pDec = String.new

      pDec << self.getTypeName(var.vtype);
        
      if var.passBy.upcase == "REFERENCE"
        pDec << ""
      end
      if var.isPointer
        pDec << ""
      end
        
      pDec << " " << self.getStyledVariableName(var);

      return pDec
    end
    
    # Returns variable declaration for the specified variable
    def getVarDec(var)
      vDec = String.new

      vDec << var.visibility << " "

      if var.isConst
        vDec << "const "
      end
        
      if var.isStatic
        vDec << "static "
      end

      if var.isVirtual
        vDec << "virtual "
      end

      if (var.templateType != nil)
        vDec << var.templateType << "<" << self.getTypeName(var.vtype) << ">"
      elsif (var.listType != nil)
        vDec << var.listType << "<" << self.getTypeName(var.vtype) << ">"
      else
        vDec << self.getTypeName(var.vtype)
      end

      vDec << " "

      if var.nullable
        vDec << "?"
      end

      vDec << self.getStyledVariableName(var)

      if (var.genGet != nil || var.genSet != nil)
        vDec << " { "
        if (var.genGet != nil)
          vDec << "get; "
        end
        if (var.genSet != nil)
          vDec << "set; "
        end
        vDec << "}"
      else        
        vDec << ";"
      end
      
      if var.comment != nil
        vDec << "\t/** " << var.comment << " */";
      end
            
      return vDec
    end
      
    # Returns a size constant for the specified variable
    def getSizeConst(var)
      return "ARRAYSZ_" << var.name.upcase
    end

    # Returns the version of this name styled for this language
    def getStyledVariableName(var)
      if var.is_a?(CodeElemVariable)
        if (var.genGet || var.genSet)
          return CodeNameStyling.getStyled(var.name, @langProfile.functionNameStyle)
        else
          return CodeNameStyling.getStyled(var.name, @langProfile.variableNameStyle)
        end
      else
        return CodeNameStyling.getStyled(var, @langProfile.variableNameStyle)
      end
    end

    # Capitalizes the first letter of a string
    def getCapitalizedFirst(str)
      newStr = String.new
      newStr += str[0,1].capitalize

      if (str.length > 1)
        newStr += str[1..str.length - 1]
      end
      
      return(newStr)
    end
    
    # Get the extension for a file type
    def getExtension(eType)
      return @langProfile.getExtension(eType)
    end
    
    # Returns 
    def getTypeAbbrev(var)
        if var.vtype == "Boolean"
          return "Bool"
        end
        if var.vtype == "Char"  	
          return "Char"
        end
        if var.vtype == "Int8"  	
          return "Char"
        end
        if var.vtype == "UChar"  	
          return "UChar"
        end
        if var.vtype == "Int16"  
          return "Short"
        end
        if var.vtype == "Int32"  
          return "Int"
        end
        if var.vtype == "UInt8"  
          return "UChar"
        end
        if var.vtype == "UInt16" 
          return "UShort"
        end
        if var.vtype == "UInt32" 
          return "UInt"
        end
        if var.vtype == "Float32"
          return "Float"
        end
        if var.vtype == "Float64"
          return "Double"
        end
        if var.vtype == "Decimal"
          return "Decimal"
        end
        if var.vtype == "UNC16"  
          return "WChar"
        end
        
        if var.vtype == "String"
          return "String"
        end
        
        # It all else fails just return the type sent in
        return var.vtype
    end
    
    def getComment(var)
      return "/* " << var.text << " */\n"
    end

    def getZero(var)
        if var.vtype == "Char"
          return "0"
        end
        if var.vtype == "Int8"
          return "0"
        end
        if var.vtype == "UChar"
          return "0"
        end
        if var.vtype == "Int16"
          return "0"
        end
        if var.vtype == "Int32"
          return "0"
        end
        if var.vtype == "UInt8"
          return "0"
        end
        if var.vtype == "UInt16"
          return "0"
        end
        if var.vtype == "UInt32"
          return "0"
        end
        if var.vtype == "Float32"
          return "0.0f"
        end
        if var.vtype == "Float64"
          return "0.0"
        end

        return "0"
    end

    def isPrimitive(var)
      return @langProfile.isPrimitive(var)
    end

    def getDataListInfo(classXML)
      dInfo = Hash.new

      classXML.elements.each("DATA_LIST_TYPE") { |dataListXML|
        dInfo['csharpTemplateType'] = dataListXML.attributes['csharpTemplateType']
      }

      return(dInfo);
    end

    # generate includes list for file
    def genIncludes(includesList, codeBuilder)

      for inc in includesList
        codeBuilder.add('using ' + inc.path + ';');
      end

      if !includesList.empty?
        codeBuilder.add
      end
    end

    def genFunctionDependencies(dataModel, genClass, cfg, codeBuilder)
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
    end

    def genNamespaceStart(namespaceList, codeBuilder)
      # Process namespace items
      if namespaceList != nil
        codeBuilder.startBlock("namespace " << namespaceList.join('.'))
      end
    end

    def genNamespaceEnd(namespaceList, codeBuilder)
      if namespaceList != nil
        codeBuilder.endBlock(" // namespace " + namespaceList.join('.'))
        codeBuilder.add
      end
    end

    def getStandardName(dataModel)
      return self.getStyledClassName(dataModel.name)
    end

    def getLangugageProfile
      return @langProfile
    end
  end
end
