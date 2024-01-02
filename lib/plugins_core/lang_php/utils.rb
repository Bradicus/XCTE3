##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require 'lang_profile'
require 'utils_base'

module XCTEPhp
  class Utils < UtilsBase
    # Get a parameter declaration for a method parameter
    def self.getParamDec(var)
      pDec = String.new

      pDec << getTypeName(var.vtype)

      pDec << " dataSet['" << var.name << "']"

      return pDec
    end

    # Returns variable declaration for the specified variable
    def self.getVarDec(var)
      vDec = String.new

      if !var.comment.nil?
        vDec << '/** ' << var.comment << " */\n    "
      end

      if var.isConst
        vDec << 'define("' << var.name << '");'
      else
        vDec << 'protected $' << var.name
      end

      vDec << ';'

      return vDec
    end

    # Get a parameter declaration for a method parameter
    def self.getTypeName(gType)
      return @@langProfile.getTypeName(gType)
    end

    # Get the extension for a file type
    def self.getExtension(eType)
      return @@langProfile.getExtension(eType)
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def self.getComment(var)
      return '/* ' << var.text << ' */'
    end

    def self.is_primitive(var)
      return @@langProfile.is_primitive(var)
    end

    def self.getDataListInfo(classXML)
      dInfo = {}

      classXML.elements.each('DATA_LIST_TYPE') do |dataListXML|
        dInfo['varClassName'] = dataListXML.attributes['lType']
        dInfo['cppTemplateType'] = dataListXML.attributes['cppTemplateType']
      end

      return(dInfo)
    end

    # Capitalizes the first letter of a string
    def self.getCapitalizedFirst(str)
      newStr = String.new
      newStr += str[0, 1].capitalize

      if str.length > 1
        newStr += str[1..str.length - 1]
      end

      return(newStr)
    end
  end
end
