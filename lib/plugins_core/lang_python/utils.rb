##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require 'lang_profile.rb'
require 'utils_base'

module XCTEPython
  class Utils < UtilsBase
    include Singleton

    def initialize
      super('python')
    end

    # Get a parameter declaration for a method parameter
    def getParamDec(var)
      pDec = String.new

      pDec << getTypeName(var);

      pDec << " " << var.name;

      return pDec
    end

    # Returns variable declaration for the specified variable
    def getVarDec(var)
      vDec = String.new

      if var.isStatic
        vDec << ""
      end

      vDec << "" << var.name;

      if var.arrayElemCount.to_i > 0
        vDec << " = []"
      end

      if var.comment != nil
        vDec << "\t# " << var.comment;
      end

      vDec << "\n";

      return vDec
    end

    # Returns a size constant for the specified variable
    def getSizeConst(var)
      return "ARRAYSZ_" << var.name.upcase
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def getComment(var)
      return "# " << var.text << " \n"
    end
  end
end
