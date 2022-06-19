##

#
# Copyright (C) 2008 Brad Ottoson
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
    def get_definition(cls, genFun, cfg, codeBuilder)
      codeBuilder.add("///")
      codeBuilder.add("/// Web API get single " + cls.model.name)
      codeBuilder.add("///")

      codeBuilder.startFunction("public IQueryable<" + Utils.instance.getStyledClassName(cls.model.name) + "> Get" + Utils.instance.getStyledClassName(cls.model.name) + "(int id)")

      get_body(cls, genFun, cfg, codeBuilder)

      codeBuilder.endFunction
    end

    def get_declairation(cls, genFun, cfg, codeBuilder)
      codeBuilder.add("public IQueryable<" + Utils.instance.getStyledClassName(cls.model.name) +
                      "> Get" + Utils.instance.getStyledClassName(cls.model.name) + "(int id);")
    end

    def get_dependencies(cls, genFun, cfg, codeBuilder)
      cls.addUse("System.Collections.Generic", "List")
      cls.addUse("System.Web.Http", "ApiController")
    end

    def get_body(cls, genFun, cfg, codeBuilder)
      conDef = String.new
      varArray = Array.new
      engineName = Utils.instance.getStyledClassName(cls.model.name) + "Engine"
      cls.model.getAllVarsFor(varArray)

      codeBuilder.add("using (SqlConnection conn = new SqlConnection())")
      codeBuilder.startBlock("using (I" + engineName + " eng = new " + engineName + "())")

      codeBuilder.add("var obj = eng.RetrieveOneById(id);")

      codeBuilder.endBlock()
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodWebApiRead.new)
