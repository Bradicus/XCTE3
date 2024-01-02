##
#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information for the function code structure
# read in from an xml file

require 'code_elem_var_group'

module CodeStructure
  class CodeElemFunction < CodeElem
    attr_accessor :name, :description, :visibility, :parameters, :isConst,
                  :isStatic, :isVirtual, :isInline, :isTemplate, :returnValue,
                  :variableReferences, :annotations, :role

    def initialize(parentElem)
      super(parentElem)

      @elementId = CodeElem::ELEM_FUNCTION

      @parameters = CodeElemVarGroup.new # Array of CodeElemVariable
      @variableReferences = [] # Array of variables
      @isConst = false
      @isStatic = false
      @isVirtual = false
      @isInline = false
      @isTemplate = false
      @annotations = []
      @returnValue = CodeElemVariable.new(self)
      @returnValue.vtype = 'void'
    end

    def add_param(param)
      parameters.vars.push(param)
    end
  end
end
