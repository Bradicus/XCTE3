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
  class MethodToDerived < XCTEPlugin
    def initialize
      @name = "method_to_derived"
      @language = "java"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, fun)
      bld.add("/*")
      bld.add("* Data model to derived model " + cls.getUName())
      bld.add("*/")

      @derivedRef = DataLoading::ClassRefLoader.loadClassRef(@xmlNode.elements["derived_class"], nil, cls.genCfg)
      @derivedClass = Classes.findClass(derivedRef.className, derivedRef.pluginName)

      @dataRef = DataLoading::ClassRefLoader.loadClassRef(@xmlNode.elements["data_class"], nil, cls.genCfg)
      @dataClass = Classes.findClass(dataRef.className, dataRef.pluginName)

      @mapParams = Array.new

      @mapParams.push(Utils.instance.getStyledClassName(@dataClass.getUName()) + " src")
      @mapParams.push(Utils.instance.getStyledClassName(@derivedClass.getUName()) + " dst")

      @funName = Utils.instance.getStyledFunctionName(@dataClass.getUName() + " to " + @derivedClass.getUName())

      get_body(cls, bld, fun)
    end

    def get_declairation(cls, bld, fun)
      bld.add("public " + @funName + "(" + mapParams.join(", ") + ");")
    end

    def process_dependencies(cls, bld, fun)
      dataClass = Utils.instance.get_data_class(cls)
    end

    def get_body(cls, bld, fun)
      conDef = String.new
      params = Array.new
      idVar = cls.model.getIdentityVar()

      bld.add("public " + @funName + "(" + mapParams.join(", ") + ")")

      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodToDerived.new)
