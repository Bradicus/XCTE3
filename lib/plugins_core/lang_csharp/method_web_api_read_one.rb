##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin"
require "code_name_styling"
require "plugins_core/lang_csharp/utils"

module XCTECSharp
  class MethodWebApiRead < XCTEPlugin
    def initialize
      @name = "method_web_api_read_one"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def render_function(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      bld.add("///")
      bld.add("/// Web API get single " + cls.get_u_name)
      bld.add("///")

      get_body(cls, bld, fun)

      bld.endFunction
    end

    def get_declairation(cls, bld, _fun)
      bld.add("public " + Utils.instance.style_as_class(cls.get_u_name) +
              " Get" + Utils.instance.style_as_class(cls.get_u_name) + "(int id);")
    end

    def process_dependencies(cls, _fun)
      cls.addUse("System.Collections.Generic", "List")
      cls.addUse("System.Web.Http", "ApiController")
      Utils.instance.add_class_include(cls, "class_standard")
      Utils.instance.add_class_include(cls, "tsql_data_store")
    end

    def get_body(cls, bld, _fun)
      conDef = String.new
      engineName = Utils.instance.style_as_class(cls.get_u_name + " data store")

      pkeys = []
      cls.model.getPrimaryKeyVars(pkeys)
      params = []
      for pkey in pkeys
        params << Utils.instance.get_param_dec(pkey)
      end

      bld.start_function("public " + Utils.instance.style_as_class(cls.get_u_name) +
                         " Get" + Utils.instance.style_as_class(cls.get_u_name) +
                         "(" + params.join(", ") + ")")

      bld.start_block("using (SqlConnection conn = new SqlConnection())")
      bld.add("I" + engineName + " eng = new " + engineName + "();")

      bld.add("var obj = eng.RetrieveOneById(id, conn);")
      bld.add("return obj;")

      bld.end_block
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECSharp::MethodWebApiRead.new)
