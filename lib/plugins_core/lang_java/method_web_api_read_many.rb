##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "code_name_styling"
require "plugins_core/lang_java/utils"
require "plugins_core/lang_java/method_web_api_base"

module XCTEJava
  class MethodWebApiReadMany < MethodWebApiBase
    def initialize
      @name = "method_web_api_read_many"
      @language = "java"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def render_function(cls, bld, fun)
      bld.add("/*")
      bld.add("* Web API get many " + cls.get_u_name)
      bld.add("*/")

      @dsClass = cls.model.findClassSpecByPluginName("class_data_set")

      if !@dsClass.nil?
        @returnType = Utils.instance.get_styled_class_name(@dsClass.get_u_name)
      else
        @returnType = "FilteredPageRespTpl<" + Utils.instance.get_styled_class_name(cls.get_u_name) + ">"
      end

      get_body(cls, bld, fun)
    end

    def process_dependencies(cls, bld, fun)
      cls.addUse("org.springframework.data.domain.PageRequest")
      cls.addUse("org.springframework.data.domain.Sort")
      cls.addUse("org.springframework.data.domain.Page")
      cls.addUse("com.example.demo.dto.FilteredPageRespTpl")
      cls.addUse("java.util.function.Function")

      @dsClass = cls.model.findClassSpecByPluginName("class_data_set")

      Utils.instance.requires_class_type(cls, cls, "class_data_set") if !@dsClass.nil?

      Utils.instance.requires_class_type(cls, cls, "class_filter_util")

      super
    end

    def get_declairation(cls, bld, _fun)
      bld.add("public " + @returnType + " Get" + Utils.instance.get_styled_class_name(cls.get_u_name) + "s(" + params.join(", ") + ");")
    end

    def get_body(cls, bld, fun)
      conDef = String.new
      data_class = Utils.instance.get_data_class(cls)
      dataStoreName =
        CodeNameStyling.getStyled(data_class.get_u_name + " data store", Utils.instance.langProfile.variableNameStyle)
      mapperName =
        "mapper"
      mapperClassName =
        CodeNameStyling.getStyled(data_class.get_u_name + " mapper", Utils.instance.langProfile.classNameStyle)

      params = []

      if !cls.model.data_filter.paging.page_size_default.nil?
        pageSize = cls.model.data_filter.paging.page_size_default
      elsif cls.model.data_filter.paging.page_sizes.length > 0
        pageSize = cls.model.data_filter.paging.page_size_default
      else
        pageSize = 1000000
      end

      if !cls.model.data_filter.sort.default_sort_column.nil?
        sortCol = cls.model.data_filter.sort.default_sort_column
      elsif cls.model.data_filter.sort.sortable_columns.length > 0
        sortCol = cls.model.data_filter.sort.sortable_columns[0]
      else
        sortCol = ""
      end

      if !cls.model.data_filter.sort.default_sort_direction.nil?
        defaultSortDir = cls.model.data_filter.sort.default_sort_direction
      else
        defaultSortDir = "asc"
      end

      params.push('@RequestParam(defaultValue="0") Integer pageNum')
      params.push('@RequestParam(defaultValue="' + pageSize.to_s + '") Integer pageSize')
      params.push('@RequestParam(defaultValue="' + sortCol + '") String sortBy')
      params.push('@RequestParam(defaultValue="true") Boolean sortAsc')

      if cls.model.data_filter.has_search_filter?
        if cls.model.data_filter.search_filter.type == "shared"
          params.push('@RequestParam(defaultValue="") String ' +
                      Utils.instance.style_as_variable(cls.model.data_filter.search_filter.get_name))
        else
          for col in cls.model.data_filter.search_filter.columns
            params.push('@RequestParam(defaultValue="") String ' +
                        Utils.instance.style_as_variable(col))
          end
        end
      end

      bld.add('@GetMapping(path = "' + Utils.instance.getStyledUrlName(cls.get_u_name) + '", produces = MediaType.APPLICATION_JSON_VALUE)')

      bld.start_function_paramed("public " + @returnType + " Get" +
                                 Utils.instance.get_styled_class_name(cls.get_u_name) + "s", params)

      bld.add "Sort sort = null;"
      bld.start_block "if (sortBy.length() > 0 && sortBy.length() > 0)"
      bld.add "sort = Filter.getSort(sortBy, sortAsc);"
      bld.end_block

      bld.separate

      if cls.model.data_filter.paging.page_sizes.length > 0
        bld.add "if (pageSizes.size() > 0 && !pageSizes.contains(pageSize))"
        bld.iadd "pageSize = pageSizes.get(0);"
      end

      bld.separate
      bld.add "PageRequest pageRequest = Filter.getPageRequest(pageNum, pageSize, sort);"
      bld.add "Page<" + Utils.instance.get_styled_class_name(data_class.get_u_name) + "> items;"

      if cls.model.data_filter.has_non_paging_filters?
        fun = Utils.instance.get_search_fun(data_class, cls)

        paramVars = []

        paramVars.push("pageRequest")

        filter_params = fun.parameters.vars.drop(1)

        if cls.model.data_filter.has_search_filter?
          if cls.model.data_filter.has_shared_filter?
            for funParam in filter_params
              paramVars.push(Utils.instance.style_as_variable(cls.model.data_filter.search_filter.get_name))
            end
          else
            for col in cls.model.data_filter.search_filter.columns
              paramVars.push(
                Utils.instance.style_as_variable(col)
              )
            end
          end
        end

        bld.render_function_call("items", dataStoreName, fun, paramVars)
      else
        bld.add "items = " + dataStoreName + ".findAll(pageRequest);"
      end

      bld.separate

      to_type = Utils.instance.get_styled_class_name(cls.get_u_name)

      if !@dsClass.nil?
        from_type = Utils.instance.get_styled_class_name(@dsClass)
        bld.add "var response = new " + @returnType + "();"
        bld.add "var mappedItems = items.map(item -> " + mapperName + ".mapTo" + Utils.instance.get_styled_class_name(cls.get_u_name) + "(item));"
        bld.add "response.items = mappedItems;"
        bld.separate
        bld.add("return response;")
      elsif !cls.data_class.nil?
        from_type = Utils.instance.get_styled_class_name(data_class.get_u_name)

        bld.start_block "var mappedItems = items.map(new Function<" + from_type + ", " + to_type + ">()"
        bld.add "@Override"
        bld.start_block "public " + to_type + " apply(" + from_type + " item)"
        bld.add to_type + " dto = new " + to_type + "();"
        bld.add "mapper.map(item, dto);"
        bld.add "return dto;"
        bld.end_block
        bld.end_block ");"

        bld.add "var response = new " + @returnType + "();"
        bld.add "response.pageCount = items.getTotalPages();"
        bld.add "response.data = mappedItems.getContent();"
      else
        bld.add "var response = new " + @returnType + "();"
        bld.add "response.data = items.getContent();"
        bld.add "response.pageCount = items.getTotalPages();"
      end

      bld.add "response.pageNum = pageNum.intValue();"
      bld.add "response.pageSize = pageSize;"
      bld.add "response.sortBy = sortBy;"

      bld.separate
      bld.add("return response;")

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEJava::MethodWebApiReadMany.new)
