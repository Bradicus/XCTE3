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
  class MethodWebApiReadOneEF < XCTEPlugin
    def initialize
      @name = "method_web_api_read_one_ef"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, fun)
      bld.add("///")
      bld.add("/// Web API get single " + cls.getUName())
      bld.add("///")

      bld.startFunction("public " + Utils.instance.getStyledClassName(cls.getUName()) + " Get" + Utils.instance.getStyledClassName(cls.getUName()) + "(int id)")

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
    end

    def get_body(cls, bld, fun)
      conDef = String.new
      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      bld.add(cls.xmlElement)

      bld.endBlock()
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodWebApiReadOneEF.new)
