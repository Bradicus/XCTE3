##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin"
require "code_name_styling"
require "plugins_core/lang_java/utils"

module XCTEJava
  class MethodMap < XCTEPlugin
    def initialize
      @name = "method_map"
      @language = "java"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def render_function(cls, bld, fun)
      @fromParam = load_param(cls, fun, "fromClass")
      @toParam = load_param(cls, fun, "toClass")

      @genReverse = (fun.data_node.attributes["gen_reverse"] == "true")
      @genListMap = (fun.data_node.attributes["gen_list_map"] == "true")

      if @fromParam.cls.nil? || @toParam.cls.nil?
        Log.missingClassRef(@fromParam.ref) if @fromParam.cls.nil?
        Log.missingClassRef(@toParam.ref) if @toParam.cls.nil?
      else
        gen_single_mapper(cls, bld, @fromParam, @toParam)

        gen_single_mapper(cls, bld, @toParam, @fromParam) if @genReverse

        genListMapper(cls, bld, fun) if @genListMap
      end
    end

    def load_param(cls, fun, elemName)
      param = MapParam.new

      param.ref = DataLoading::ClassRefLoader.loadClassRef(fun.data_node.elements[elemName], nil, cls.gen_cfg)
      param.cls = ClassModelManager.findClass(param.ref.model_name, param.ref.plugin_name)
      param.name = Utils.instance.get_styled_class_name(param.cls.get_u_name)

      return param
    end

    def gen_single_mapper(_cls, bld, fParam, tParam)
      @mapParams = []

      @mapParams.push(fParam.name + " src")
      @mapParams.push("@MappingTarget " + tParam.name + " dst")

      bld.add("/*")
      bld.add("* Map -" + fParam.cls.get_u_name + "- to -" + tParam.cls.get_u_name + "-")
      bld.add("*/")

      bld.add("public void map(" + @mapParams.join(", ") + ");")
      bld.add("public " + tParam.name + " mapTo" + tParam.name + "(" + fParam.name + " src);")
    end

    def genListMapper(_cls, bld, _fun)
      @mapParams = []

      @mapParams.push("List<" + Utils.instance.get_styled_class_name(@fromParam.cls.get_u_name) + "> srcList")
      @mapParams.push("@MappingTarget List<" + Utils.instance.get_styled_class_name(@toParam.cls.get_u_name) + "> dstList")

      bld.separate

      bld.add("/*")
      bld.add("* Map -List<" + @fromParam.name + ">- to -List<" + @toParam.cls.get_u_name + ">-")
      bld.add("*/")

      bld.add("public void updateList(" + @mapParams.join(", ") + ");")
    end

    def process_dependencies(cls, _bld, fun)
      @fromParam = load_param(cls, fun, "fromClass")
      @toParam = load_param(cls, fun, "toClass")

      cls.addUse("java.util.List")

      if @fromParam.cls.nil? || @toParam.cls.nil?
        Log.missingClassRef(@fromRef) if @fromParam.cls.nil?
        Log.missingClassRef(@toRef) if @toParam.cls.nil?
      else
        Utils.instance.requires_class_type(cls, @toParam.cls, "class_db_entity")
        Utils.instance.requires_class_type(cls, @fromParam.cls, "class_standard")
      end
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEJava::MethodMap.new)
