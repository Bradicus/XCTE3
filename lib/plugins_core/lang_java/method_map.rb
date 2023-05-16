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
      @fromClass = ClassPluginManager.findClass(@fromRef.className, @fromRef.pluginName)

      @toRef = DataLoading::ClassRefLoader.loadClassRef(fun.xmlElement.elements["toClass"], nil, cls.genCfg)
      @toClass = ClassPluginManager.findClass(@toRef.className, @toRef.pluginName)

      @genReverse = (fun.xmlElement.attributes["gen_reverse"] == "true")
      @genListMap = (fun.xmlElement.attributes["gen_list_map"] == "true")

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

          bld.separate

          @mapParams.push(Utils.instance.getStyledClassName(@toClass.getUName()) + " src")
          @mapParams.push(Utils.instance.getStyledClassName(@fromClass.getUName()) + " dst")

          bld.add("/*")
          bld.add("* Map -" + @toClass.getUName() + "- to -" + @fromClass.getUName() + "-")
          bld.add("*/")

          @funName = Utils.instance.getStyledFunctionName(@toClass.getUName() + " to " + @fromClass.getUName())
          get_body(cls, bld, fun)
        end

        if (@genListMap)
          genListMapper(cls, bld, fun)
          genPageMapper(cls, bld, fun)
        end
      end
    end

    def genListMapper(cls, bld, fun)
      @fromRef = DataLoading::ClassRefLoader.loadClassRef(fun.xmlElement.elements["toClass"], nil, cls.genCfg)
      @fromClass = ClassPluginManager.findClass(@fromRef.className, @fromRef.pluginName)

      @toRef = DataLoading::ClassRefLoader.loadClassRef(fun.xmlElement.elements["fromClass"], nil, cls.genCfg)
      @toClass = ClassPluginManager.findClass(@toRef.className, @toRef.pluginName)

      @mapParams = Array.new

      @mapParams.push("List<" + Utils.instance.getStyledClassName(@fromClass.getUName()) + "> srcList")
      @mapParams.push("List<" + Utils.instance.getStyledClassName(@toClass.getUName()) + "> dstList")

      bld.separate

      bld.add("/*")
      bld.add("* Map -List<" + @fromClass.getUName() + ">- to -List<" + @toClass.getUName() + ">-")
      bld.add("*/")

      bld.startFunction("public void mapList(" + @mapParams.join(", ") + ")")
      bld.add "int i = 0;"
      bld.add "while (dstList.size() < srcList.size())"
      bld.iadd "dstList.add(new " + Utils.instance.getStyledClassName(@toClass.getUName()) + "());"
      bld.separate
      bld.startBlock("for (var src: srcList)")
      bld.add "var dst = dstList.get(i);"
      bld.add "mapper.map(src, dst);"
      bld.add "i++;"
      bld.endBlock
      bld.endFunction
    end

    def genPageMapper(cls, bld, fun)
      @fromRef = DataLoading::ClassRefLoader.loadClassRef(fun.xmlElement.elements["toClass"], nil, cls.genCfg)
      @fromClass = ClassPluginManager.findClass(@fromRef.className, @fromRef.pluginName)
      @fromClassName = Utils.instance.getStyledClassName(@fromClass.getUName())

      @toRef = DataLoading::ClassRefLoader.loadClassRef(fun.xmlElement.elements["fromClass"], nil, cls.genCfg)
      @toClass = ClassPluginManager.findClass(@toRef.className, @toRef.pluginName)
      @toClassName = Utils.instance.getStyledClassName(@toClass.getUName())

      @mapParams = Array.new

      @mapParams.push("Page<" + @fromClassName + "> srcPage")
      #@mapParams.push("Page<" + Utils.instance.getStyledClassName(@toClass.getUName()) + "> dstPage")

      bld.separate

      bld.add("/*")
      bld.add("* Map -Page<" + @fromClass.getUName() + ">- to -Page<" + @toClass.getUName() + ">-")
      bld.add("*/")

      bld.startFunction("public Page<" + @toClassName + "> mapPage(" + @mapParams.join(", ") + ")")
      bld.startBlock "Page<" + @toClassName + "> dstPage = srcPage.map(new Function<" + @fromClassName + ", " + @toClassName + ">()"
      bld.add "@Override"
      bld.startBlock "public " + @toClassName + " apply(" + @fromClassName + " entity)"
      bld.add "var dto = new " + @toClassName + "();"
      bld.add "mapper.map(entity, dto);"
      bld.add "return dto;"
      bld.endBlock
      bld.endBlock ");"
      bld.add "return dstPage;"
      bld.endFunction
    end

    def get_declairation(cls, bld, fun)
      bld.add("public void " + @funName + "(" + mapParams.join(", ") + ");")
    end

    def process_dependencies(cls, bld, fun)
      @fromRef = DataLoading::ClassRefLoader.loadClassRef(fun.xmlElement.elements["fromClass"], nil, cls.genCfg)
      @fromClass = ClassPluginManager.findClass(@fromRef.className, @fromRef.pluginName)

      @toRef = DataLoading::ClassRefLoader.loadClassRef(fun.xmlElement.elements["toClass"], nil, cls.genCfg)
      @toClass = ClassPluginManager.findClass(@toRef.className, @toRef.pluginName)

      cls.addUse("java.util.List")

      if @fromClass == nil || @toClass == nil
        if @fromClass == nil
          Log.missingClassRef(@fromRef)
        end
        if @toClass == nil
          Log.missingClassRef(@toRef)
        end
      else
        Utils.instance.requires_class_type(cls, @toClass, "class_jpa_entity")
        Utils.instance.requires_class_type(cls, @fromClass, "standard")
      end
    end

    def get_body(cls, bld, fun)
      conDef = String.new
      params = Array.new
      idVar = cls.model.getIdentityVar()

      bld.startFunction("public void map(" + @mapParams.join(", ") + ")")
      bld.add "mapper.map(src, dst);"
      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodMap.new)
