##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information for the variable group code structure
# read in from an xml file

require 'code_structure/code_elem'

module CodeStructure
  class CodeElemVarGroup < CodeStructure::CodeElem
    attr_accessor :name, :vars, :varGroups

    def initialize
      super(CodeStructure::CodeElemTypes::ELEM_VAR_GROUP, nil)

      @name = String.new

      @vars = []
      @varGroups = []
    end

    def add_var(var)
      @vars << var
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
