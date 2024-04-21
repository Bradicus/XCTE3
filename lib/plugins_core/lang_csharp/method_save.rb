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
  class MethodSave < XCTEPlugin
    def initialize
      @name = "method_save"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def render_function(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec
      bld.add("///")
      bld.add("/// Save all components of this object")
      bld.add("///")

      bld.start_function("public void Save()")

      get_body(cls, bld, fun)

      bld.endFunction
    end

    def get_declairation(_cls, bld, _fun)
      bld.add("void Save();")
    end

    def process_dependencies(cls, _bld, _fun)
      cls.addUse("System", "Exception")
      cls.addUse("System.Data.SqlClient", "SqlConnection")
    end

    def get_body(cls, bld, _fun)
      conDef = String.new
      varArray = []
      cls.model.getAllVarsFor(varArray)

      bld.add("_conn.Open();")

      for var in varArray
        if Utils.instance.is_primitive(var) == false
          varCreateFun = ProjectPlan.instance.findClassFunction(@language, var.utype, "tsql_engine",
                                                                "method_tsql_create")
          if !varCreateFun.nil?
            bld.add("_" + Utils.instance.get_styled_variable_name(var, "") + ".Create(o);")
          end
        end
      end
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECSharp::MethodSave.new)
