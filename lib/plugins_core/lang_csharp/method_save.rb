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
  class MethodSave < XCTEPlugin
    def initialize
      @name = "method_save"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, fun)
      bld.add("///")
      bld.add("/// Save all components of this object")
      bld.add("///")

      bld.startFunction("public void Save()")

      get_body(cls, bld, fun)

      bld.endFunction
    end

    def get_declairation(cls, bld, fun)
      bld.add("void Save();")
    end

    def process_dependencies(cls, bld, fun)
      cls.addUse("System", "Exception")
      cls.addUse("System.Data.SqlClient", "SqlConnection")
    end

    def get_body(cls, bld, fun)
      conDef = String.new
      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      bld.add("_conn.Open();")

      for var in varArray
        if (Utils.instance.isPrimitive(var) == false)
          varCreateFun = ProjectPlan.instance.findClassFunction(@language, var.utype, "tsql_engine", "method_tsql_create")
          if varCreateFun != nil
            bld.add("_" + Utils.instance.getStyledVariableName(var, "") + ".Create(o);")
          end
        end
      end
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodSave.new)
