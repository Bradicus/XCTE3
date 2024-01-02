##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require 'lang_profile'
require 'utils_base'
require 'log'
require 'ref_finder'
require 'plugins_core/lang_tsql/utils'

module XCTEJava
  class Utils < UtilsBase
    include Singleton

    def initialize
      super('java')
    end

    # Get a parameter declaration for a method parameter
    def getParamDec(var)
      pDec = String.new

      pDec << getTypeName(var)

      pDec << ' ' << get_styled_variable_name(var)

      return pDec
    end

    # Returns variable declaration for the specified variable
    def getVarDec(var)
      vDec = String.new

      vDec << var.visibility << ' '

      vDec << 'const ' if var.isConst

      vDec << 'static ' if var.isStatic

      vDec << 'virtual ' if var.isVirtual

      vDec << getTypeName(var)

      vDec << ' '

      vDec << '?' if var.nullable

      vDec << get_styled_variable_name(var)
      vDec << ';'

      vDec << "\t/** " << var.comment << ' */' if !var.comment.nil?

      return vDec
    end

    # def getFullType(var)
    #   fType = ""

    #   if (var.templateType != nil)
    #     fType << var.templateType << "<" << self.getTypeName(var) << ">"
    #   elsif (var.listType != nil)
    #     fType << var.listType << "<" << self.getTypeName(var) << ">"
    #   else
    #     fType << self.getTypeName(var)
    #   end
    # end

    def getFullOjbType(var)
      fType = ''

      if !var.templateType.nil?
        fType += var.templateType + '<' + getTypeName(var) + '>'
      elsif !var.listType.nil?
        fType += var.listType + '<' + getTypeName(var) + '>'
      else
        fType += getTypeName(var)
      end
    end

    # Return the language type based on the generic type
    def getTypeName(var)
      typeName = getSingleItemTypeName(var)

      if var.templates.length > 0 && var.templates[0].isCollection
        tplType = @langProfile.getTypeName(var.templates[0].name)
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
      langType = @langProfile.getTypeName(var.getUType)

      if !var.utype.nil? # Only unformatted name needs styling
        baseTypeName = CodeNameStyling.getStyled(langType, @langProfile.classNameStyle)
      else
        baseTypeName = langType
      end

      # if var.namespace.hasItems?()
      #   nsPrefix = var.namespace.get("::") + "::"
      #   baseTypeName = nsPrefix + baseTypeName
      # end

      return baseTypeName
    end

    # Return the language type based on the generic type
    def getObjTypeName(var)
      return CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle) if var.vtype.nil?

      objType = getType(var.vtype + 'obj')
      return objType.langType if !objType.nil?

      return @langProfile.getTypeName(var.vtype)
    end

    # Returns a size constant for the specified variable
    def getSizeConst(var)
      return CodeNameStyling.getStyled('max len ' + var.name, @langProfile.constNameStyle)
    end

    # Get the extension for a file type
    def getExtension(eType)
      return @langProfile.getExtension(eType)
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def getComment(var)
      return '/* ' << var.text << " */\n"
    end

    # Capitalizes the first letter of a string
    def getCapitalizedFirst(str)
      newStr = String.new
      newStr += str[0, 1].capitalize

      newStr += str[1..str.length - 1] if str.length > 1

      return(newStr)
    end

    def getStyledUrlName(name)
      return CodeNameStyling.getStyled(name, 'DASH_LOWER')
    end

    def process_var_dependencies(cls, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE && !is_primitive(var)
          varCls = ClassModelManager.findVarClass(var)
          fPath = getStyledFileName(var.getUType + '')
          cls.addInclude(varCls.path + '/' + fPath + '.module', get_styled_class_name(var.getUType + ' module'))
        end
      end

      for grp in vGroup.varGroups
        process_var_dependencies(cls, bld, grp)
      end
    end

    def requires_var(cls, var)
      # varClass = ClassModelManager.findVarClass(var)
      varClassAndPlug = RefFinder.find_class_by_type(cls.genCfg.language, var.getUType)
      # requires_other_class_type(cls, varClass, varClass.plug.name)

      return unless !varClassAndPlug.nil? && !cls.namespace.same?(varClassAndPlug.cls.namespace)

      cls.addUse(varClassAndPlug.cls.namespace.get('.') + '.*')
    end

    def requires_other_class_type(cls, _otherCls, plugName)
      plugNameClass = cls.model.findClassModelByPluginName(plugName)
      return if cls.namespace.same?(plugNameClass.namespace)

      cls.addUse(plugNameClass.namespace.get('.') + '.*')
    end

    def requires_class_type(cls, fromCls, plugName)
      plugNameClass = fromCls.model.findClassModelByPluginName(plugName)

      if plugNameClass.nil?
        Log.error('unable to find class by type ' + plugName)
      elsif plugNameClass.namespace.nsList.length == 0
        throw 'Zero length namespace'
      else
        cls.addUse(plugNameClass.namespace.get('.') + '.*')
      end
    end

    def requires_class_ref(cls, classRef)
      plugNameClass = ClassModelManager.findClass(classRef.model_name, classRef.plugin_name)

      if plugNameClass.nil?
        Log.error('unable to find class by ref ')
      else
        cls.addUse(plugNameClass.namespace.get('.') + '.*')
      end
    end

    def get_data_class(cls)
      if !cls.dataClass.nil?
        dataClass = ClassModelManager.findClass(cls.dataClass.model_name, cls.dataClass.plugin_name)
        return dataClass if !dataClass.nil?
      end

      return cls
    end

    def add_class_injection(toCls, fromCls, plugName)
      varClass = fromCls.model.findClassModelByPluginName(plugName)
      if !varClass.nil?
        var = createVarFor(varClass, plugName)
        var.visibility = 'private'

        if !var.nil?
          toCls.addInjection(var)
          requires_var(toCls, var)
        end
      else
        Log.error('Unable to find class type ' + plugName + ' for model ' + fromCls.model.name)
      end
    end

    def get_search_fun(cls, filtered_class)
      fun = CodeStructure::CodeElemFunction.new(nil)

      if !filtered_class.dataClass.nil?
        data_class = ClassModelManager.findClass(filtered_class.dataClass.model_name, filtered_class.dataClass.plugin_name)
        pageReqVar = createVarFor(data_class, data_class.plugName)
      else
        data_class = cls
        pageReqVar = createVarFor(data_class, 'class_jpa_entity')
      end

      throw('could not find class_jpa_entity for ' + data_class.model.name) if pageReqVar.nil?

      pageReqVar.templates.push(CodeStructure::CodeElemTemplate.new('Page'))
      fun.returnValue = pageReqVar

      col_name_cointain = []
      pageVar = CodeStructure::CodeElemVariable.new(nil)
      pageVar.name = 'pageRequest'
      pageVar.vtype = 'PageRequest'
      fun.add_param(pageVar)

      if needs_custom_query? filtered_class.model.data_filter
        tableVar = CodeNameStyling.getStyled(data_class.model.name, XCTETSql::Utils.instance.langProfile.variableNameStyle)
        talbeName = CodeNameStyling.getStyled(data_class.model.name, XCTETSql::Utils.instance.langProfile.classNameStyle)
        query = 'SELECT ' + tableVar + ' FROM ' + talbeName + ' ' + tableVar + ' WHERE '

        if !filtered_class.model.data_filter.static_filters.empty?
          static_compares = []
          for filter in filtered_class.model.data_filter.static_filters
            col_var = data_class.model.get_var_by_name(filter.column)
            static_compares.push(get_sql_equality_compare(col_var, filter.value))
          end
        end

        if !filtered_class.model.data_filter.search.columns.empty?
          search_compares = []
          for col in filtered_class.model.data_filter.search.columns
            col_var = data_class.model.get_var_by_name(col)
            search_compares.push(
              get_sql_equality_like(col_var,
                                    CodeNameStyling.getStyled(col,
                                                              XCTETSql::Utils.instance.langProfile.variableNameStyle))
            )
            fun.add_param(col_var)
          end

          query += '(' + static_compares.join(' OR ') + ') AND (' + search_compares.join(' OR ') + ')'
        end

        fun.annotations.push('@Query("' + query + '")')

        fun.name = get_styled_function_name(filtered_class.model.data_filter.search.name)
      else
        for col in filtered_class.model.data_filter.search.columns
          col_var = data_class.model.get_var_by_name(col)

          if col_var.nil?
            throw('Could not find column variable named ' + col)
          end

          add_jpa_function_part_for(col_name_cointain, col_var, nil)
          fun.add_param(col_var)
        end

        for static_filter in filtered_class.model.data_filter.static_filters
          static_filter_var = data_class.model.get_var_by_name(static_filter.column)
          add_jpa_function_part_for(col_name_cointain, static_filter_var, static_filter)
        end

        fun.name = 'findBy' + col_name_cointain.join('Or')
        # else # Statif filter but no search filter
        #   fun.name = 'findBy' + get_styled_class_name(cls.model.data_filter.static_filters[0].column)
        #   searchVar = data_class.data_class.model.get_var_by_name(cls.model.data_filter.static_filters[0].column)
        #   if !searchVar.nil? && searchVar.getUType == 'boolean'
        #     fun.name += value.capitalize
      end

      return fun
    end

    def needs_search_fun_declaration?(fun, filtered_class)
      return fun.parameters.vars.length > 1 ||
             !filtered_class.model.data_filter.static_filters.empty? ||
             fun.parameters.has_bool_param?
    end

    def needs_custom_query?(data_filter)
      return !data_filter.search.columns.empty? && !data_filter.static_filters.empty?
    end

    def get_sql_equality_compare(var, value)
      if var.is_bool?
        return get_styled_variable_name(var) + '=' + (value.downcase == 'true' ? 'true' : 'false')
      elsif is_numeric?(var)
        return get_styled_variable_name(var) + '=' + value
      else
        return get_styled_variable_name(var) + "='" + value + "'"
      end
    end

    def get_sql_equality_like(var, value)
      if var.is_bool?
        return get_sql_equality_compare(var, value)
      elsif is_numeric?(var)
        return get_styled_variable_name(var) + '=' + value
      else
        get_styled_variable_name(var) + " LIKE CONCAT('%',:" +
          get_styled_variable_name(var) + ",'%')"
      end
    end

    def add_jpa_function_part_for(col_name_cointain, filter_var, static_filter)
      if !filter_var.nil? && filter_var.is_bool?
        if !static_filter.nil?
          value_text = static_filter.value.capitalize
        else
          value_text = ''
        end
        col_name_cointain.push(get_styled_class_name(filter_var.name) + value_text)
      else
        col_name_cointain.push(get_styled_class_name(filter_var.name) + 'Contains')
      end
    end

    def render_fun_call(_bld, _fun)
      return get_styled_function_name(col) + '(' + ')'
    end
  end
end
