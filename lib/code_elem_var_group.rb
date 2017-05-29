##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information for the variable group code structure
# read in from an xml file

require 'code_elem.rb'

module CodeStructure
  class CodeElemVarGroup < CodeElem
    attr_accessor :name, :vars, :groups

    def initialize
      @elementId = CodeElem::ELEM_VAR_GROUP
      @name = String.new

      @vars = Array.new
      @groups = Array.new
    end
  end
end
