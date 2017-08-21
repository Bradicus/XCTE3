##
# @author Brad Ottoson
# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class contains the language profile for C++ and utility fuctions
# used by various plugins
 
require 'code_name_styling.rb'
require 'utils_base.rb'
require 'singleton'

module XCTECpp
  class Utils < UtilsBase
    include Singleton

    def initialize
      super('cpp')
    end
    
    # Get a parameter declaration for a method parameter
    def getParamDec(var)
      pDec = String.new
        
      if var.isConst
        pDec << "const "     
      end
      if var.isStatic
        pDec << "static "
      end
        
      pDec << getTypeName(var.vtype);
        
      if var.passBy.upcase == "REFERENCE"
        pDec << "&"
      end
      if var.isPointer
        pDec << "*"
      end
        
      pDec << " " << getStyledVariableName(var)
      
      if var.arrayElemCount > 0
        pDec << "[]"
      end
      
      return pDec
    end
    
    # Returns variable declaration for the specified variable
    def getVarDec(var)
      vDec = String.new
        
      if var.isConst
        vDec << "const "
      end
        
      if var.isStatic
        vDec << "static "
      end
      
      typeName = getTypeName(var.vtype);

      if var.isPointer
        typeName << "*";
      end

      if (var.templateType != nil)
        vDec << var.templateType << "<" << typeName << ">"
      elsif (var.listType != nil)
        vDec << getTypeName(var.listType) << "<" << typeName << ">"
      else
        vDec << typeName
      end
      
      if var.passBy.upcase == "REFERENCE"
        vDec << "&";
      end
      
      vDec << " " << getStyledVariableName(var)
      
      if var.arrayElemCount.to_i > 0
        vDec << "[" + getSizeConst(var) << "]"
      end
        
      vDec << ";"
      
      if var.comment != nil
        vDec << "\t/** " << var.comment << " */";
      end
      
      return vDec
    end
  
    # Returns a size constant for the specified variable
    def getSizeConst(var)
      return "ARRAYSZ_" << var.name.upcase
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
    
    def getComment(var)
      return "/* " << var.text << " */\n"
    end

    def getZero(var)
        if var.vtype == "Float32"
          return "0.0f"
        end
        if var.vtype == "Float64"
          return "0.0"
        end

        return "0"
    end

    def getDataListInfo(classXML)
      dInfo = Hash.new

      classXML.elements.each("DATA_LIST_TYPE") { |dataListXML|
        dInfo['cppTemplateType'] = dataListXML.attributes['cppTemplateType']
      }

      return(dInfo);
    end

  end
end
