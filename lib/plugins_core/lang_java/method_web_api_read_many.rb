##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'code_name_styling'
require 'plugins_core/lang_java/utils'
require 'plugins_core/lang_java/method_web_api_base'

module XCTEJava
  class MethodWebApiReadMany < MethodWebApiBase
    def initialize
      @name = 'method_web_api_read_many'
      @language = 'java'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, fun)
      bld.add('/*')
      bld.add('* Web API get many ' + cls.getUName)
      bld.add('*/')

      @dsClass = cls.model.findClassModelByPluginName('class_data_set')

      if !@dsClass.nil?
        @returnType = Utils.instance.get_styled_class_name(@dsClass.getUName)
      else
        @returnType = 'FilteredPageRespTpl<' + Utils.instance.get_styled_class_name(cls.getUName) + '>'
      end

      get_body(cls, bld, fun)
    end

    def process_dependencies(cls, bld, fun)
      cls.addUse('org.springframework.data.domain.PageRequest')
      cls.addUse('org.springframework.data.domain.Sort')
      cls.addUse('org.springframework.data.domain.Page')
      cls.addUse('com.example.demo.dto.FilteredPageRespTpl')

      @dsClass = cls.model.findClassModelByPluginName('class_data_set')

      Utils.instance.requires_class_type(cls, cls, 'class_data_set') if !@dsClass.nil?

      Utils.instance.requires_class_type(cls, cls, 'class_filter_util')

      super
    end

    def get_declairation(cls, bld, _fun)
      bld.add('public ' + @returnType + ' Get' + Utils.instance.get_styled_class_name(cls.getUName) + 's(' + params.join(', ') + ');')
    end

    def get_body(cls, bld, fun)
      conDef = String.new
      dataClass = Utils.instance.get_data_class(cls)
      dataStoreName =
        CodeNameStyling.getStyled(dataClass.getUName + ' data store', Utils.instance.langProfile.variableNameStyle)
      mapperName =
        'mapper'
      mapperClassName =
        CodeNameStyling.getStyled(dataClass.getUName + ' mapper', Utils.instance.langProfile.classNameStyle)

      params = []

      if !cls.model.data_filter.paging.page_size_default.nil?
        pageSize = cls.model.data_filter.paging.page_size_default
      elsif cls.model.data_filter.paging.page_sizes.length > 0
        pageSize = cls.model.data_filter.paging.page_size_default
      else
        pageSize = 1_000_000
      end

      if !cls.model.data_filter.sort.default_sort_column.nil?
        sortCol = cls.model.data_filter.sort.default_sort_column
      elsif cls.model.data_filter.sort.sortable_columns.length > 0
        sortCol = cls.model.data_filter.sort.sortable_columns[0]
      else
        sortCol = ''
      end

      if !cls.model.data_filter.sort.default_sort_direction.nil?
        defaultSortDir = cls.model.data_filter.sort.default_sort_direction
      else
        defaultSortDir = 'asc'
      end

      params.push('@RequestParam(defaultValue="0") Integer pageNum')
      params.push('@RequestParam(defaultValue="' + pageSize.to_s + '") Integer pageSize')
      params.push('@RequestParam(defaultValue="' + sortCol + '") String sortBy')
      params.push('@RequestParam(defaultValue="true") Boolean sortAsc')
      params.push('@RequestParam(defaultValue="") String searchValue')

      bld.add('@GetMapping(path = "' + Utils.instance.getStyledUrlName(cls.getUName) + '", produces = MediaType.APPLICATION_JSON_VALUE)')

      bld.startFunctionParamed('public ' + @returnType + ' Get' +
                               Utils.instance.get_styled_class_name(cls.getUName) + 's', params)

      bld.add 'Sort sort = null;'
      bld.startBlock 'if (sortBy.length() > 0 && sortBy.length() > 0)'
      bld.add 'sort = Filter.getSort(sortBy, sortAsc);'
      bld.endBlock

      bld.separate

      if cls.model.data_filter.paging.page_sizes.length > 0
        bld.add 'if (pageSizes.size() > 0 && !pageSizes.contains(pageSize))'
        bld.iadd 'pageSize = pageSizes.get(0);'
      end

      bld.separate
      bld.add 'PageRequest pageRequest = Filter.getPageRequest(pageNum, pageSize, sort);'
      bld.add 'Page<' + Utils.instance.get_styled_class_name(dataClass.getUName) + '> items;'

      if cls.model.data_filter.has_non_paging_filters?
        fun = Utils.instance.get_search_fun(dataClass, cls)
        paramVars = []

        paramVars.push('pageRequest')

        for funParam in fun.parameters.vars.drop(1)
          paramVars.push('searchValue')
        end

        bld.render_function_call('items', dataStoreName, fun, paramVars)
      else
        bld.add 'items = ' + dataStoreName + '.findAll(pageRequest);'
      end

      bld.separate
      if !@dsClass.nil?
        bld.add 'var dataSet = new ' + @returnType + '();'
        bld.add 'var mappedItems = items.map(item -> ' + mapperName + '.mapTo' + Utils.instance.get_styled_class_name(cls.getUName) + '(item));'
        bld.add 'dataSet.items = mappedItems;'
        bld.separate
        bld.add('return dataSet;')
      elsif !cls.dataClass.nil?
        bld.add 'var mappedItems = items.map(item -> ' + mapperName + '.mapTo' + Utils.instance.get_styled_class_name(cls.getUName) + '(item));'
        bld.add 'var response = new ' + @returnType + '();'
        bld.add 'response.pageCount = mappedItems.getTotalPages();'
        bld.add 'response.data = mappedItems.getContent();'
      else
        bld.add 'var response = new ' + @returnType + '();'
        bld.add 'response.data = items.getContent();'
        bld.add 'response.pageCount = items.getTotalPages();'
      end

      bld.add 'response.pageNum = pageNum.intValue();'
      bld.add 'response.pageSize = pageSize;'
      bld.add 'response.sortBy = sortBy;'
      bld.add 'response.searchValue = searchValue;'

      bld.separate
      bld.add('return response;')

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEJava::MethodWebApiReadMany.new)
