##

#
# Copyright (C) 2017 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_cpp/x_c_t_e_cpp.rb"
require "classes"

module XCTECpp
  class MethodNlohmannJsonRead < XCTEPlugin
    def initialize
      @name = "method_nlohmann_json_read"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
      @standardClass
      @standardClassType
    end

    # Returns declairation string for this class's constructor
    def get_declaration(dataModel, genClass, codeFun, codeBuilder)
      getStandardClassInfo(dataModel, genClass, codeFun, codeBuilder)

      codeBuilder.add("static void read(const nlohmann::json& json, " +
                      @standardClassType + "& item);")
    end

    # Returns declairation string for this class's constructor
    def get_declaration_inline(dataModel, genClass, codeFun, codeBuilder)
      getStandardClassInfo(dataModel, genClass, codeFun, codeBuilder)

      codeBuilder.startFuction("static void read(const nlohmann::json& json, " +
                               @standardClassType + "& item);")
      codeStr << get_body(dataModel, genClass, codeFun, codeBuilder)
      codeBuilder.endFunction
    end

    #
    def getStandardClassInfo(dataModel, genClass, codeFun, codeBuilder)
      @standardClass = dataModel.findClass("standard")

      if (@standardClass.namespaceList != nil)
        ns = @standardClass.namespaceList.join("::") + "::"
      else
        ns = ""
      end

      @standardClassType = ns + Utils.instance.getStyledClassName(@standardClass.name)

      if (@standardClass != nil && @standardClass.ctype != "enum")
        genClass.addInclude(@standardClass.namespaceList.join("/"), Utils.instance.getStyledClassName(dataModel.name))
      end
    end

    def get_dependencies(dataModel, genClass, codeFun, codeBuilder)
      genClass.addInclude("", "json.hpp")

      # Add dependecies for all variables that aren't primitives, and their engines
      varArray = Array.new
      dataModel.getAllVarsFor(varArray)

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          if (!Utils.instance.isPrimitive(var) && !Utils.instance.getTypeName(var).end_with?("Type"))
            #genClass.addInclude(var.namespace, Utils.instance.getTypeName(var) )
            genClass.addInclude(genClass.namespaceList.join("/"), Utils.instance.getClassName(var) + "JsonEngine")
          end
        end
      end
    end

    # Returns definition string for this class's constructor
    def get_definition(dataModel, genClass, codeFun, codeBuilder)
      codeBuilder.add("/**")
      codeBuilder.add("* Reads this classes primitives from a json element")
      codeBuilder.add("*/")

      classDef = String.new
      classDef << Utils.instance.getTypeName(codeFun.returnValue) << " " <<
        Utils.instance.getStyledClassName(genClass.name) << " :: " << "read(const nlohmann::json& json, " +
                                                                      @standardClassType + "& item)"
      codeBuilder.startClass(classDef)

      get_body(dataModel, genClass, codeFun, codeBuilder)

      codeBuilder.endFunction
    end

    def get_body(dataModel, genClass, codeFun, codeBuilder)
      conDef = String.new
      varArray = Array.new
      dataModel.getAllVarsFor(varArray)

      codeBuilder.startBlock("if (json.is_null() == false)")

      standardClass = Classes.findClass("standard")

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          curVarName = Utils.instance.getStyledVariableName(var)
          curVarType = Utils.instance.getTypeName(var)
          curVarClass = Classes.findVarClass(var)
          isEnum = curVarClass != nil && curVarClass.ctype == "enum"

          if (Utils.instance.isPrimitive(var) || isEnum)
            if var.listType == nil
              codeBuilder.add('if (json.find("' + Utils.instance.getStyledVariableName(var) + '") != json.end()) item.' + Utils.instance.getStyledVariableName(var) +
                              ' = json["' + Utils.instance.getStyledVariableName(var) + '"].get<' + Utils.instance.getTypeName(var) + ">();")
            else
              codeBuilder.startBlock('for (auto child : json["' + Utils.instance.getStyledVariableName(var) + '"])')
              codeBuilder.add("item." + Utils.instance.getStyledVariableName(var) + ".push_back(child.get<" + Utils.instance.getTypeName(var) + ">());")
              codeBuilder.endBlock
            end
          else
            if var.listType == nil
              codeBuilder.add(
                Utils.instance.getClassName(var) + "JsonEngine::read(" +
                  'json["' + Utils.instance.getStyledVariableName(var) + '"], item.' + Utils.instance.getStyledVariableName(var) + ");"
              )
            else
              codeBuilder.startBlock('for (auto aJson : json["' + Utils.instance.getStyledVariableName(var) + '"])')

              codeBuilder.add(Utils.instance.getTypeName(var) + " newVar;")
              codeBuilder.add(Utils.instance.getClassName(var) + "JsonEngine::read(aJson, newVar);")
              codeBuilder.add("item." + Utils.instance.getStyledVariableName(var) + ".push_back(newVar);")

              codeBuilder.endBlock
            end
          end
        end
      end

      codeBuilder.endBlock
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodNlohmannJsonRead.new)
