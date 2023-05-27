##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "code_name_styling.rb"
require "plugins_core/lang_java/utils.rb"
require "plugins_core/lang_java/method_web_api_base"

module XCTEJava
  class MethodWebApiReadMany < MethodWebApiBase
    def initialize
      @name = "method_web_api_read_many"
      @language = "java"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, fun)
      bld.add("/*")
      bld.add("* Web API get single " + cls.getUName())
      bld.add("*/")

      @dsClass = cls.model.findClassModelByPluginName("class_data_set")

      if @dsClass != nil
        @returnType = Utils.instance.getStyledClassName(@dsClass.getUName())
      else
        @returnType = "Page<" + Utils.instance.getStyledClassName(cls.getUName()) + ">"
      end

      get_body(cls, bld, fun)
    end

    def process_dependencies(cls, bld, fun)
      cls.addUse("org.springframework.data.domain.PageRequest")
      cls.addUse("org.springframework.data.domain.Sort")
      cls.addUse("org.springframework.data.domain.Page")

      @dsClass = cls.model.findClassModelByPluginName("class_data_set")

      if @dsClass != nil
        Utils.instance.requires_class_type(cls, cls, "class_data_set")
      end

      Utils.instance.requires_class_type(cls, cls, "class_filter_util")

      super
    end

    def get_declairation(cls, bld, fun)
      bld.add("public " + @returnType + " Get" + Utils.instance.getStyledClassName(cls.getUName()) + "s(" + params.join(", ") + ");")
    end

    def get_body(cls, bld, fun)
      conDef = String.new
      dataClass = Utils.instance.get_data_class(cls)
      dataStoreName =
        CodeNameStyling.getStyled(dataClass.getUName() + " data store", Utils.instance.langProfile.variableNameStyle)
      mapperName =
        CodeNameStyling.getStyled(dataClass.getUName() + " mapper", Utils.instance.langProfile.variableNameStyle)

      pageNumStr = fun.xmlElement.attributes["page_filter"]

      if pageNumStr != nil
        pageNums = pageNumStr.split(",")
      else
        pageNums = Array.new
      end

      params = Array.new

      params.push('@RequestParam("pageNum") Long pageNum')
      params.push('@RequestParam("pageSize") Long pageSize')
      params.push('@RequestParam("sortBy") String sortBy')
      params.push('@RequestParam("sortAsc") String sortOrder')
      params.push('@RequestParam("search") String search')

      bld.add('@GetMapping(path = "' + Utils.instance.getStyledUrlName(cls.getUName()) + '", produces = MediaType.APPLICATION_JSON_VALUE)')

      bld.startFunctionParamed("public " + @returnType + " Get" +
                               Utils.instance.getStyledClassName(cls.getUName()) + "s", params)

      bld.add "Sort sort = Filter.getSort(sortBy, sortOrder);"
      bld.add "PageRequest pageRequest = Filter.getPageRequest(pageNum, pageSize, sort);"

      bld.separate

      bld.add("var items = " + dataStoreName + ".findAll(pageRequest);")

      if @dsClass != nil
        bld.add "var dataSet = new " + @returnType + "();"
        bld.add "var mappedItems = " + mapperName + ".mapPage(items);"
        bld.add "dataSet.items = mappedItems;"
        bld.separate
        bld.add("return dataSet;")
      elsif cls.dataClass != nil
        bld.add "var mappedItems = " + mapperName + ".mapPage(items);"
        bld.add("return mappedItems;")
        bld.separate
      else
        bld.add("return items;")
      end

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodWebApiReadMany.new)
