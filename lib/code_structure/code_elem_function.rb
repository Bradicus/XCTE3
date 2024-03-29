##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information for the function code structure
# read in from an xml file

require 'code_structure/code_elem_var_group'
require 'code_structure/code_elem'

module CodeStructure
  class CodeElemFunction < CodeElem
    attr_accessor :name, :description, :visibility, :parameters, :isConst,
                  :isStatic, :isVirtual, :isInline, :isTemplate, :returnValue,
                  :annotations, :role

    def initialize(parentElem)
      super(CodeStructure::CodeElemTypes::ELEM_FUNCTION, parentElem)

      @parameters = CodeElemVarGroup.new # Array of CodeElemVariable
      @isConst = false
      @isStatic = false
      @isVirtual = false
      @isInline = false
      @isTemplate = false
      @annotations = []
      @returnValue = CodeElemVariable.new(self)
      @returnValue.vtype = 'void'
    end


    def add_var(var)
      parameters.vars.push(var)
    end

    def add_param(param)
      if param != nil
        parameters.vars.push(param)
      end
    end

    def add_unique_param(param)
      if param != nil

        found = false

        for pvar in parameters.vars
          if pvar.name == param.name
            found = true
          end
        end

        if !found
          parameters.vars.push(param)
        end
      end
    end

    def add_param_from(name, type, visibility = nil)
      add_param CodeElemVariable.new(self).init_as_param(name, type, visibility)
    end
  end
end
