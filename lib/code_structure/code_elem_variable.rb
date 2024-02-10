##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information for the variable code structure
# read in from an xml file

require 'code_structure/code_elem_template'
require 'code_structure/code_elem'

module CodeStructure
  class CodeElemVariable < CodeElem
    attr_accessor :vtype, :utype, :defaultValue, :comment,
                  :visibility, :isConst, :isStatic, :isSharedPointer, :isVirtual, :init, :passBy, :genSet, :genGet,
                  :arrayElemCount, :nullable, :identity, :isPrimary, :namespace, :selectFrom, :isOptions_list,
                  :templates, :attribs, :required, :readonly, :relation, :storeIn, :init_vars

    def initialize(parentElem)
      super(CodeStructure::CodeElemTypes::ELEM_VARIABLE, parentElem)

      @isVirtual = false
      @isConst = false
      @isStatic = false
      @isSharedPointer = false
      @init = nil
      @namespace = CodeElemNamespace.new
      @passBy = 'value'
      @genSet = false
      @genGet = false
      @nullable = false
      @identity = nil
      @isPrimary = false
      @selectFrom = nil
      @isOptions_list = false
      @templates = []
      @attribs = []

      @required = false
      @readonly = false
      @relation = nil
      @storeIn = nil
      @init_vars = false

      # Stored only for arrays
      @arrayElemCount = 0	# Array size of 0 means this isn't an array

      # puts "[CodeElemVariable::initialize] Creating variable"
    end

    # Returns parameter version of this variable, that can be used in function calls to pass data that
    # can later be assigned to this variable.
    def getParam
      param = CodeElemVariable.new(@parentElem)
      param.name = @name
      param.vtype = @vtype
      param.utype = @utype
      param.templates = @templates
      param.arrayElemCount = @arrayElemCount

      return param
    end

    def getUType
      if utype.nil?
        return vtype
      end

      return utype
    end

    def getdisplay_name
      if !display_name.nil?
        return display_name
      end

      return name.capitalize
    end

    def hasMultipleItems
      return isArray() || isList()
    end

    def hasSet
      return !listType.nil?
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
        if tpl.downcase == tplName.downcase
          return true
        end
      end

      return false
    end

    def needsValidation
      return @readonly || @required || @arrayElemCount > 0
    end

    def isList(depth = 0)
      if @templates.length <= depth
        return false
      end

      return @templates[depth].isCollection
    end

    def isArray
      return arrayElemCount > 0
    end

    def isPointer(depth = 0)
      if @templates.length <= depth
        return false
      end

      return !@templates[depth].pointerTpl.nil?
    end

    def is_bool?
      return getUType().downcase == 'boolean'
    end

    def hasOneToOneRelation
      return !@relation.nil? && @relation.start_with?('one-to-one')
    end

    def hasOneToManyRelation
      return !@relation.nil? && @relation.start_with?('one-to-many')
    end

    def hasManyToManyRelation
      return !@relation.nil? && @relation.start_with?('many-to-many')
    end
  end
end
