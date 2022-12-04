##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin.rb"
require "code_name_styling.rb"
require "plugins_core/lang_csharp/utils.rb"

module XCTECSharp
  class MethodWebApiRead < XCTEPlugin
    def initialize
      @name = "method_web_api_read_one"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, fun)
      bld.add("///")
      bld.add("/// Web API get single " + cls.getUName())
      bld.add("///")

      get_body(cls, bld, fun)

      bld.endFunction
    end

    def get_declairation(cls, bld, fun)
      bld.add("public " + Utils.instance.getStyledClassName(cls.getUName()) +
              " Get" + Utils.instance.getStyledClassName(cls.getUName()) + "(int id);")
    end

    def process_dependencies(cls, bld, fun)
      cls.addUse("System.Collections.Generic", "List")
      cls.addUse("System.Web.Http", "ApiController")
      Utils.instance.addClassInclude(cls, "standard")
      Utils.instance.addClassInclude(cls, "tsql_data_store")
    end

    def get_body(cls, bld, fun)
      conDef = String.new
      engineName = Utils.instance.getStyledClassName(cls.getUName() + " data store")

      pkeys = Array.new
      cls.model.getPrimaryKeyVars(pkeys)
      params = Array.new
      for pkey in pkeys
        params << Utils.instance.getParamDec(pkey)
      end

      bld.startFunction("public " + Utils.instance.getStyledClassName(cls.getUName()) +
                        " Get" + Utils.instance.getStyledClassName(cls.getUName()) +
                        "(" + params.join(", ") + ")")

      bld.startBlock("using (SqlConnection conn = new SqlConnection())")
      bld.add("I" + engineName + " eng = new " + engineName + "();")

      bld.add("var obj = eng.RetrieveOneById(id, conn);")
      bld.add("return obj;")

      bld.endBlock()
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodWebApiRead.new)
