##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require 'lang_profile'
require 'utils_base'

module XCTEPython
  class Utils < UtilsBase
    include Singleton

    def initialize
      super('python')
    end

    # Get a parameter declaration for a method parameter
    def get_param_dec(var)
      pDec = String.new

      pDec << get_type_name(var)

      pDec << ' ' << var.name

      return pDec
    end

    # Returns variable declaration for the specified variable
    def getVarDec(var)
      vDec = String.new

      if var.isStatic
        vDec << ''
      end

      vDec << '' << var.name

      if var.arrayElemCount.to_i > 0
        vDec << ' = []'
      end

      if !var.comment.nil?
        vDec << "\t# " << var.comment
      end

      vDec << "\n"

      return vDec
    end

    # Returns a size constant for the specified variable
    def get_size_const(var)
      return 'ARRAYSZ_' << var.name.upcase
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def getComment(var)
      return '# ' << var.text << " \n"
    end
  end
end
