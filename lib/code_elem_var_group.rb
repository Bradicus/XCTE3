##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information for the variable group code structure
# read in from an xml file

require 'code_elem'

module CodeStructure
  class CodeElemVarGroup < CodeElem
    attr_accessor :name, :vars, :varGroups

    def initialize
      super

      @elementId = CodeElem::ELEM_VAR_GROUP
      @name = String.new

      @vars = []
      @varGroups = []
    end

    def has_bool_param?
      for var in vars
        if var.getUType().downcase == 'boolean'
          return true
        end
      end

      return false
    end
  end
end
