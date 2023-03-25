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
  class MethodMap < XCTEPlugin
    def initialize
      @name = "method_map"
      @language = "java"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, fun)
      @fromRef = DataLoading::ClassRefLoader.loadClassRef(fun.xmlElement.elements["fromClass"], nil, cls.genCfg)
      @fromClass = Classes.findClass(@fromRef.className, @fromRef.pluginName)

      @toRef = DataLoading::ClassRefLoader.loadClassRef(fun.xmlElement.elements["toClass"], nil, cls.genCfg)
      @toClass = Classes.findClass(@toRef.className, @toRef.pluginName)

      @genReverse = (fun.xmlElement.attributes["gen_reverse"] == "true")

      if @fromClass == nil || @toClass == nil
        if @fromClass == nil
          Log.missingClassRef(@fromRef)
        end
        if @toClass == nil
          Log.missingClassRef(@toRef)
        end
      else
        @mapParams = Array.new

        @mapParams.push(Utils.instance.getStyledClassName(@fromClass.getUName()) + " src")
        @mapParams.push(Utils.instance.getStyledClassName(@toClass.getUName()) + " dst")

        bld.add("/*")
        bld.add("* Map -" + @fromClass.getUName() + "- to -" + @toClass.getUName() + "-")
        bld.add("*/")

        @funName = Utils.instance.getStyledFunctionName(@fromClass.getUName() + " to " + @toClass.getUName())
        get_body(cls, bld, fun)

        if @genReverse
          @mapParams = Array.new

          bld.add

          @mapParams.push(Utils.instance.getStyledClassName(@toClass.getUName()) + " src")
          @mapParams.push(Utils.instance.getStyledClassName(@fromClass.getUName()) + " dst")

          bld.add("/*")
          bld.add("* Map -" + @toClass.getUName() + "- to -" + @fromClass.getUName() + "-")
          bld.add("*/")

          @funName = Utils.instance.getStyledFunctionName(@toClass.getUName() + " to " + @fromClass.getUName())
          get_body(cls, bld, fun)
        end
      end
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

      bld.startFunction("public " + @funName + "(" + @mapParams.join(", ") + ")")
      bld.add "mapper.map(src,dst);"
      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodMap.new)
