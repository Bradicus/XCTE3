##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains the language profile for C++ and utility fuctions
# used by various plugins

require 'code_name_styling'
require 'utils_base'
require 'singleton'

module XCTECpp
  class Utils < UtilsBase
    include Singleton

    def initialize
      super('cpp')
    end

    # Get a parameter declaration for a method parameter
    def get_param_dec(var)
      pDec = String.new

      pDec += 'const ' if var.isConst

      pDec += get_type_name(var)

      pDec += '&' if var.passBy.upcase == 'REFERENCE'
      pDec += '*' if var.isPointer

      pDec += ' ' + get_styled_variable_name(var)

      pDec += '[]' if var.arrayElemCount > 0

      return pDec
    end

    # Returns variable declaration for the specified variable
    def get_var_dec(var)
      vDec = String.new
      typeName = String.new

      vDec += 'const ' if var.isConst

      vDec += 'static ' if var.isStatic

      vDec += get_type_name(var)

      vDec += '*' if var.isPointer

      vDec += '&' if var.passBy.upcase == 'REFERENCE'

      vDec += ' ' + get_styled_variable_name(var)

      vDec += '[' + get_size_const(var) + ']' if var.arrayElemCount.to_i > 0

      vDec += ';'

      vDec += "\t/** " + var.comment + ' */' if !var.comment.nil?

      return vDec
    end

    # Returns a size constant for the specified variable
    def get_size_const(var)
      return 'ARRAYSZ_' + var.name.upcase
    end

    # Capitalizes the first letter of a string
    def getCapitalizedFirst(str)
      newStr = String.new
      newStr += str[0, 1].capitalize

      newStr += str[1..str.length - 1] if str.length > 1

      return(newStr)
    end

    # Return the language type based on the generic type
    def get_type_name(var)
      typeName = getSingleItemTypeName(var)

      if var.templates.length > 0 && var.templates[0].isCollection
        tplType = @langProfile.get_type_name(var.templates[0].name)
        typeName = tplType + '<' + typeName + '>'
      end

      return typeName
    end

    def getSingleItemTypeName(var)
      typeName = getBaseTypeName(var)

      singleTpls = var.templates
      singleTpls = singleTpls.drop(1) if singleTpls.length > 0 && singleTpls[0].isCollection

      for tpl in singleTpls.reverse
        typeName = tpl.name + '<' + typeName + '>'
      end

      return typeName.strip
    end

    # Return the language type based on the generic type
    def getBaseTypeName(var)
      nsPrefix = ''
      langType = @langProfile.get_type_name(var.getUType)

      if !var.utype.nil? # Only unformatted name needs styling
        baseTypeName = CodeNameStyling.getStyled(langType, @langProfile.classNameStyle)
      else
        baseTypeName = langType
      end

      if var.namespace.hasItems?
        nsPrefix = var.namespace.get('::') + '::'
        baseTypeName = nsPrefix + baseTypeName
      end

      return baseTypeName
    end

    def get_class_name(var)
      return @langProfile.get_type_name(var.vtype) if !var.vtype.nil?

      return CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle)
    end

    def getClassTypeName(cls)
      nsPrefix = ''
      nsPrefix = cls.namespace.get('::') + '::' if cls.namespace.hasItems?

      baseTypeName = CodeNameStyling.getStyled(cls.name, @langProfile.classNameStyle)
      baseTypeName = nsPrefix + baseTypeName

      if cls.templateParams.length > 0
        allParams = []

        for param in cls.templateParams
          allParams.push(CodeNameStyling.getStyled(param.name, @langProfile.classNameStyle))
        end

        baseTypeName += '<' + allParams.join(', ') + '>'
      end

      return baseTypeName
    end

    def getDerivedClassPrefix(cls)
      tplNames = []
      for tplParam in cls.templateParams
        tplNames.push(tplParam.name)
      end

      return CodeNameStyling.getStyled(cls.name, @langProfile.classNameStyle) + tplNames.join('') if tplNames.length > 0

      return CodeNameStyling.getStyled(cls.name, @langProfile.classNameStyle)
    end

    def getListTypeName(listTypeName)
      return @langProfile.get_type_name(listTypeName)
    end

    def getComment(var)
      return '/* ' + var.text + " */\n"
    end

    def getZero(var)
      return '0.0f' if var.vtype == 'Float32'
      return '0.0' if var.vtype == 'Float64'

      return '0'
    end

    def getDataListInfo(classXML)
      dInfo = {}

      classXML.elements.each('DATA_LIST_TYPE') do |dataListXML|
        dInfo['cppTemplateType'] = dataListXML.attributes['cppTemplateType']
      end

      return(dInfo)
    end

    # Retrieve the standard version of this model's class
    def getStandardClassInfo(cls)
      cls.standardClass = cls.model.findClassSpecByPluginName('standard')

      if cls.standardClass.namespace.hasItems?
        ns = cls.standardClass.namespace.get('::') + '::'
      else
        ns = ''
      end

      cls.standardClassType = ns + Utils.instance.get_styled_class_name(cls.getUName)

      if !cls.standardClass.nil? && cls.standardClass.plug_name != 'enum'
        cls.addInclude(cls.standardClass.namespace.get('/'), Utils.instance.get_styled_class_name(cls.getUName))
      end

      return cls.standardClass
    end
  end
end
