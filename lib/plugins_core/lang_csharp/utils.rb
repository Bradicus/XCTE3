##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains the language profile for CSharp and utility fuctions
# used by various plugins

require 'lang_profile'
require 'code_name_styling'
require 'utils_base'
require 'singleton'

module XCTECSharp
  class Utils < UtilsBase
    include Singleton

    def initialize
      super('csharp')
    end

    def get_sql_util(cls)
      if cls.model.findClassSpecByPluginName('tsql_data_store') != nil
        return XCTETSql::Utils.instance
      else
        return XCTESql::Utils.instance
      end
    end

    # Get a parameter declaration for a method parameter
    def get_param_dec(var)
      pDec = String.new

      pDec << get_type_name(var)

      pDec << ' ' << get_styled_variable_name(var)

      return pDec
    end

    # Returns variable declaration for the specified variable
    def get_var_dec(var)
      vDec = String.new

      vDec << var.visibility << ' '

      vDec << 'const ' if var.isConst

      vDec << 'static ' if var.isStatic

      vDec << 'virtual ' if var.isVirtual

      vDec << get_type_name(var)

      vDec << ' '

      vDec << '?' if var.nullable

      vDec << get_styled_variable_name(var)

      if !var.genGet.nil? || !var.genSet.nil?
        vDec << ' { '
        vDec << 'get; ' if !var.genGet.nil?
        vDec << 'set; ' if !var.genSet.nil?
        vDec << '}'
      else
        vDec << ';'
      end

      vDec << "\t/** " << var.comment << ' */' if !var.comment.nil?

      return vDec
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
      if singleTpls.length > 0 && singleTpls[0].isCollection
        singleTpls = singleTpls.drop(1)

        typeName = getObjTypeName(var) if is_primitive(var)
      end

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

    # Return the language type based on the generic type
    def getObjTypeName(var)
      return CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle) if var.vtype.nil?

      objType = get_type(var.vtype + 'obj')
      return objType.langType if !objType.nil?

      return @langProfile.get_type_name(var.vtype)
    end

    def add_class_include(cls, plugName)
      cls_model = cls.model.findClassSpecByPluginName(plugName)
      if !cls_model.nil?
        cls.addUse(cls.model.findClassSpecByPluginName(plugName).namespace.get('.'))
      else
        Log.warn("Unabled to find class plugin " + plugName + ' for ' + cls.model.name)
      end
    end

    # Returns a size constant for the specified variable
    def get_size_const(var)
      return 'ARRAYSZ_' << CodeNameStyling.getStyled(var.name, 'UNDERSCORE_UPPER')
    end

    # Returns the version of this name styled for this language
    def get_styled_variable_name(var, varPrefix = '')
      if !var.is_a?(CodeStructure::CodeElemVariable)
        return CodeNameStyling.getStyled(var, @langProfile.variableNameStyle)
      elsif !var.genGet.nil? || !var.genSet.nil?
        return CodeNameStyling.getStyled(varPrefix + var.name, @langProfile.functionNameStyle)
      end

      return CodeNameStyling.getStyled(varPrefix + var.name, @langProfile.variableNameStyle)
    end

    # Capitalizes the first letter of a string
    def getCapitalizedFirst(str)
      newStr = String.new
      newStr += str[0, 1].capitalize

      newStr += str[1..str.length - 1] if str.length > 1

      return(newStr)
    end

    # Get the extension for a file type
    def get_extension(eType)
      return @langProfile.get_extension(eType)
    end

    def getComment(var)
      return '/* ' << var.text << " */\n"
    end

    # Should move this into language def xml
    def getZero(var)
      return '0.0f' if var.vtype == 'Float32'
      return '0.0' if var.vtype == 'Float64'

      return '0'
    end

    def requires_other_class_type(cls, plugName)
      plugNameClass = cls.model.findClassSpecByPluginName(plugName)
      return if cls.namespace.same?(plugNameClass.namespace)

      cls.addUse(plugNameClass.namespace.get('.'))
    end

    def getDataListInfo(classXML)
      dInfo = {}

      classXML.elements.each('DATA_LIST_TYPE') do |dataListXML|
        dInfo['csharpTemplateType'] = dataListXML.attributes['csharpTemplateType']
      end

      return(dInfo)
    end

    def genFunctionDependencies(cls, bld)
      # Add in any dependencies required by functions
      for fun in cls.functions
        if fun.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION && fun.isTemplate
          templ = XCTEPlugin.findMethodPlugin('csharp', fun.name)
          if !templ.nil?
            templ.process_dependencies(cls, bld, fun)
          else
            puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
          end
        end
      end
    end

    def addNonIdentityParams(cls, bld)
      varArray = []
      cls.model.getNonIdentityVars(varArray)

      addParameters(varArray, cls, bld)
    end

    def addParameters(varArray, _cls, bld)
      for var in varArray
        if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
          bld.add('cmd.Parameters.AddWithValue("@' +
                  Utils.instance.get_styled_variable_name(var) +
                  '", o.' + Utils.instance.get_styled_variable_name(var) + ');')
        elsif var.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
          bld.add(var.formatText)
        end
      end
    end

    # Generate a list of @'d parameters
    def genParamList(cls, bld, varPrefix = '')
      separator = ''
      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        bld.same_line(separator)
        bld.add('@' + get_styled_variable_name(var, varPrefix))
        separator = ','
      }))
    end

    # Generate a list of variables
    def genVarList(cls, bld, varPrefix = '')
      separator = ''
      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        bld.same_line(separator)
        bld.add('[' + XCTETSql::Utils.instance.get_styled_variable_name(var, varPrefix) + ']')
        separator = ','
      }))
    end

    def genAssignResults(cls, bld)
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && var.isList && is_primitive(var)
          resultVal = 'results["' +
                      XCTETSql::Utils.instance.get_styled_variable_name(var, cls.varPrefix) + '"]'
          objVar = 'o.' + XCTECSharp::Utils.instance.get_styled_variable_name(var)

          if var.nullable
            bld.add(objVar + ' = ' + resultVal + ' == DBNull.Value ? null : Convert.To' +
                    var.vtype + '(' + resultVal + ');')
          else
            bld.add(objVar + ' = Convert.To' +
                    var.vtype + '(' + resultVal + ');')
          end
        end
      }))
    end

    def genFunctions(cls, bld)
      # Generate code for functions
      for fun in cls.functions
        if fun.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin.findMethodPlugin('csharp', fun.name)
            if !templ.nil?
              templ.render_function(cls, fun, nil, bld)
            else
              puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
            end
          else # Must be empty function
            templ = XCTEPlugin.findMethodPlugin('csharp', 'method_empty')
            if !templ.nil?
              templ.render_function(cls, fun, nil, bld)
            else
              # puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
            end
          end

          bld.add
        end
      end
    end

    def getLangugageProfile
      return @langProfile
    end

    def getClassTypeName(cls)
      nsPrefix = ''
      nsPrefix = cls.namespace.get('.') + '.' if cls.namespace.hasItems?

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

    # Retrieve the standard version of this model's class
    def getStandardClassInfo(cls)
      cls.standardClass = cls.model.findClassSpecByPluginName('standard')

      if cls.standardClass.namespace.hasItems?
        ns = cls.standardClass.namespace.get('.') + '.'
      else
        ns = ''
      end

      cls.standardClassType = ns + Utils.instance.get_styled_class_name(cls.getUName)

      if !cls.standardClass.nil? && cls.standardClass.plugName != 'enum'
        cls.addInclude(cls.standardClass.namespace.get('/'), Utils.instance.get_styled_class_name(cls.getUName))
      end

      return cls.standardClass
    end
  end
end
