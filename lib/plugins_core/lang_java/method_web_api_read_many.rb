##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin.rb"
require "code_name_styling.rb"
require "plugins_core/lang_java/utils.rb"

module XCTEJava
  class MethodWebApiReadMany < XCTEPlugin
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

    def process_dependencies(cls, bld, fun)
      Utils.instance.requires_class_type(cls, "class_jpa_entity")
      Utils.instance.requires_class_type(cls, "tsql_data_store")
      Utils.instance.addClassInjection(cls, "tsql_data_store")
      cls.addUse("java.util.*")
    end

    def get_body(cls, bld, fun)
      conDef = String.new
      dataStoreName =
        CodeNameStyling.getStyled(cls.getUName() + " data store", Utils.instance.langProfile.variableNameStyle)

      params = Array.new

      #bld.add "@CrossOrigin"
      bld.add('@GetMapping("' + Utils.instance.getStyledUrlName(cls.getUName()) + '")')

      bld.startFunction("public List<" + Utils.instance.getStyledClassName(cls.getUName()) +
                        "> Get" + Utils.instance.getStyledClassName(cls.getUName()) +
                        "s(" + params.join(", ") + ")")

      bld.add("var items = " + dataStoreName + ".findAll();")
      bld.add("return items;")

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodWebApiReadMany.new)
