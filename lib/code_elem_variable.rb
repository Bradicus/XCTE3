##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information for the variable code structure
# read in from an xml file

require "code_elem_template"

module CodeStructure
  class CodeElemVariable < CodeElem
    attr_accessor :vtype, :utype, :defaultValue, :comment,
      :visibility, :isConst, :isStatic, :isSharedPointer, :isVirtual, :init, :passBy, :genSet, :genGet,
      :arrayElemCount, :nullable, :identity, :isPrimary, :namespace, :selectFrom, :isOptionsList,
      :templates, :attribs, :required, :readonly

    def initialize(parentElem)
      super(parentElem)

      @elementId = CodeElem::ELEM_VARIABLE

      @vtype  # Type name
      @utype  # Unformatted type name
      @defaultValue
      @comment
      @isVirtual = false
      @isConst = false
      @isStatic = false
      @isSharedPointer = false
      @init = nil
      @namespace = CodeElemNamespace.new
      @passBy = "value"
      @genSet = false
      @genGet = false
      @nullable = false
      @identity = nil
      @isPrimary = false
      @selectFrom = nil
      @isOptionsList = false
      @templates = Array.new
      @attribs = Array.new

      @required = false
      @readonly = false

      # Stored only for arrays
      @arrayElemCount = 0 	# Array size of 0 means this isn't an array

      # puts "[CodeElemVariable::initialize] Creating variable"
    end

    # Returns parameter version of this variable, that can be used in function calls to pass data that
    # can later be assigned to this variable.
    def getParam()
      param = CodeElemVariable.new(@parentElem)
      param.name = @name
      param.vtype = @vtype
      param.utype = @utype
      param.templates = @templates
      param.arrayElemCount = @arrayElemCount

      return param
    end

    def getUType()
      if (utype == nil)
        return vtype
      end

      return utype
    end

    def getDisplayName()
      if displayName != nil
        return displayName
      end

      return name.capitalize
    end

    def hasMultipleItems()
      return isArray() || isList()
    end

    def hasSet()
      return listType != nil
    end

    def addTpl(name, isCollection = false, ptrType = nil)
      tpl = CodeElemTemplate.new
      tpl.name = name
      tpl.isCollection = isCollection
      tpl.pointerTpl = ptrType
      @templates.push(tpl)
    end

    def hasTemplate(tplName)
      for tpl in @templates
        if (tpl.downcase == tplName.downcase)
          return true
        end
      end

      return false
    end

    def needsValidation()
      return @readonly || @required || @arrayElemCount > 0
    end

    def isList(depth = 0)
      if @templates.length <= depth
        return false
      end

      return @templates[depth].isCollection
    end

    def isArray()
      return arrayElemCount > 0
    end

    def isPointer(depth = 0)
      if @templates.length <= depth
        return false
      end

      return @templates[depth].pointerTpl != nil
    end
  end
end
