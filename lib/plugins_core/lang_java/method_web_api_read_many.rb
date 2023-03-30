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

      get_body(cls, bld, fun)
    end

    def get_declairation(cls, bld, fun)
      bld.add("public " + Utils.instance.getStyledClassName(cls.getUName()) +
              " Get" + Utils.instance.getStyledClassName(cls.getUName()) + "(int id);")
    end

    def get_body(cls, bld, fun)
      conDef = String.new
      dataClass = Utils.instance.get_data_class(cls)
      dataStoreName =
        CodeNameStyling.getStyled(dataClass.getUName() + " data store", Utils.instance.langProfile.variableNameStyle)
      mapperName =
        CodeNameStyling.getStyled(dataClass.getUName() + " mapper", Utils.instance.langProfile.variableNameStyle)

      params = Array.new

      #bld.add "@CrossOrigin"
      bld.add('@GetMapping("' + Utils.instance.getStyledUrlName(cls.getUName()) + '")')

      bld.startFunction("public List<" + Utils.instance.getStyledClassName(cls.getUName()) +
                        "> Get" + Utils.instance.getStyledClassName(cls.getUName()) +
                        "s(" + params.join(", ") + ")")

      bld.add("var items = " + dataStoreName + ".findAll();")

      if cls.dataClass != nil
        bld.add "var mappedItems = new List<" + Utils.instance.getStyledClassName(cls.getUName()) + ">();"
        bld.add mapperName + ".map(items, mappedItems);"
        bld.add("return mappedItems;")
      else
        bld.add("return items;")
      end

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodWebApiReadMany.new)
