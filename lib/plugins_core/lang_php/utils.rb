##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require "lang_profile"
require "utils_base"

module XCTEPhp
  class Utils < UtilsBase
    include Singleton

    def initialize
      super("php")
    end

    # Get a parameter declaration for a method parameter
    def get_param_dec(var)
      pDec = String.new

      pDec << get_type_name(var.vtype)

      pDec << " dataSet['" << var.name << "']"

      return pDec
    end

    # Returns variable declaration for the specified variable
    def get_var_dec(var)
      vDec = String.new

      if !var.comment.nil?
        vDec << "/** " << var.comment << " */\n    "
      end

      if var.isConst
        vDec << 'define("' << var.name << '");'
      else
        vDec << "protected $" << var.name
      end

      vDec << ";"

      return vDec
    end

    # Get a parameter declaration for a method parameter
    def get_type_name(gType)
      return @langProfile.get_type_name(gType)
    end

    # Get the extension for a file type
    def get_extension(eType)
      return @langProfile.get_extension(eType)
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def get_comment(var)
      return "/* " << var.text << " */"
    end

    def is_primitive(var)
      return @langProfile.is_primitive(var)
    end

    def getDataListInfo(classXML)
      dInfo = {}

      classXML.elements.each("DATA_LIST_TYPE") do |dataListXML|
        dInfo["varClassName"] = dataListXML.attributes["lType"]
        dInfo["cppTemplateType"] = dataListXML.attributes["cppTemplateType"]
      end

      return(dInfo)
    end

    # Capitalizes the first letter of a string
    def get_capitalized_first(str)
      newStr = String.new
      newStr += str[0, 1].capitalize

      if str.length > 1
        newStr += str[1..str.length - 1]
      end

      return(newStr)
    end
  end
end
