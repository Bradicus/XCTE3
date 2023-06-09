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
      @fromParam = load_param(cls, fun, "fromClass")
      @toParam = load_param(cls, fun, "toClass")

      @genReverse = (fun.xmlElement.attributes["gen_reverse"] == "true")
      @genListMap = (fun.xmlElement.attributes["gen_list_map"] == "true")

      if @fromParam.cls == nil || @toParam.cls == nil
        if @fromParam.cls == nil
          Log.missingClassRef(@fromParam.ref)
        end
        if @toParam.cls == nil
          Log.missingClassRef(@toParam.ref)
        end
      else
        gen_single_mapper(cls, bld, @fromParam, @toParam)

        if @genReverse
          gen_single_mapper(cls, bld, @toParam, @fromParam)
        end

        if (@genListMap)
          genListMapper(cls, bld, fun)
        end
      end
    end

    def load_param(cls, fun, elemName)
      param = MapParam.new

      param.ref = DataLoading::ClassRefLoader.loadClassRef(fun.xmlElement.elements[elemName], nil, cls.genCfg)
      param.cls = ClassModelManager.findClass(param.ref.className, param.ref.pluginName)
      param.name = Utils.instance.getStyledClassName(param.cls.getUName())

      return param
    end

    def gen_single_mapper(cls, bld, fParam, tParam)
      @mapParams = Array.new

      @mapParams.push(fParam.name + " src")
      @mapParams.push("@MappingTarget " + tParam.name + " dst")

      bld.add("/*")
      bld.add("* Map -" + fParam.cls.getUName() + "- to -" + tParam.cls.getUName() + "-")
      bld.add("*/")

      bld.add("public void map(" + @mapParams.join(", ") + ");")
      bld.add("public " + tParam.name + " mapTo" + tParam.name + "(" + fParam.name + " src);")
    end

    def genListMapper(cls, bld, fun)
      @mapParams = Array.new

      @mapParams.push("List<" + Utils.instance.getStyledClassName(@fromParam.cls.getUName()) + "> srcList")
      @mapParams.push("@MappingTarget List<" + Utils.instance.getStyledClassName(@toParam.cls.getUName()) + "> dstList")

      bld.separate

      bld.add("/*")
      bld.add("* Map -List<" + @fromParam.name + ">- to -List<" + @toParam.cls.getUName() + ">-")
      bld.add("*/")

      bld.add("public void updateList(" + @mapParams.join(", ") + ");")
    end

    def process_dependencies(cls, bld, fun)
      @fromParam = load_param(cls, fun, "fromClass")
      @toParam = load_param(cls, fun, "toClass")

      cls.addUse("java.util.List")

      if @fromParam.cls == nil || @toParam.cls == nil
        if @fromParam.cls == nil
          Log.missingClassRef(@fromRef)
        end
        if @toParam.cls == nil
          Log.missingClassRef(@toRef)
        end
      else
        Utils.instance.requires_class_type(cls, @toParam.cls, "class_jpa_entity")
        Utils.instance.requires_class_type(cls, @fromParam.cls, "standard")
      end
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodMap.new)
