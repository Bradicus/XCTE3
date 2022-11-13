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
    def get_definition(cls, genFun, cfg, codeBuilder)
      codeBuilder.add("///")
      codeBuilder.add("/// Save all components of this object")
      codeBuilder.add("///")

      codeBuilder.startFunction("public void Save()")

      get_body(cls, genFun, cfg, codeBuilder)

      codeBuilder.endFunction
    end

    def get_declairation(cls, genFun, cfg, codeBuilder)
      codeBuilder.add("void Save();")
    end

    def process_dependencies(cls, genFun, cfg, codeBuilder)
      cls.addUse("System", "Exception")
      cls.addUse("System.Data.SqlClient", "SqlConnection")
    end

    def get_body(cls, genFun, cfg, codeBuilder)
      conDef = String.new
      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      codeBuilder.add("_conn.Open();")

      for var in varArray
        if (Utils.instance.isPrimitive(var) == false)
          varCreateFun = ProjectPlan.instance.findClassFunction(@language, var.utype, "tsql_engine", "method_tsql_create")
          if varCreateFun != nil
            codeBuilder.add("_" + Utils.instance.getStyledVariableName(var, "") + ".Create(o);")
          end
        end
      end
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodSave.new)
