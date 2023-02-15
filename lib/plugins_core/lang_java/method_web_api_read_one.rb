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
  class MethodWebApiRead < XCTEPlugin
    def initialize
      @name = "method_web_api_read_one"
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
      dataClass = Utils.instance.get_data_class(cls)

      Utils.instance.requires_class_type(cls, dataClass, "class_jpa_entity")
      Utils.instance.requires_class_type(cls, dataClass, "tsql_data_store")
      Utils.instance.add_class_injection(cls, dataClass, "tsql_data_store")
    end

    def get_body(cls, bld, fun)
      conDef = String.new
      dataClass = Utils.instance.get_data_class(cls)
      dataStoreName =
        CodeNameStyling.getStyled(dataClass.getUName() + " data store", Utils.instance.langProfile.variableNameStyle)

      params = Array.new
      idVar = cls.model.getIdentityVar()

      if idVar != nil
        params << '@PathVariable("' + Utils.instance.getStyledVariableName(idVar) + '") ' + Utils.instance.getParamDec(idVar)
      end

      #bld.add "@CrossOrigin"
      bld.add('@GetMapping("' + Utils.instance.getStyledUrlName(cls.getUName()) + '/{id}")')

      bld.startFunction("public " + Utils.instance.getStyledClassName(cls.getUName()) +
                        " Get" + Utils.instance.getStyledClassName(cls.getUName()) +
                        "(" + params.join(", ") + ")")

      bld.add("var item = " + dataStoreName + ".findById(id);")
      bld.add("return item.get();")

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodWebApiRead.new)
