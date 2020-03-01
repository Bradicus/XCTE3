##

#
# Copyright (C) 2017 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_cpp/x_c_t_e_cpp.rb"

module XCTECpp
  class MethodNlohmannJsonWrite < XCTEPlugin
    def initialize
      @name = "method_nlohmann_json_write"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
      @standardClass
      @standardClassType
    end

    # Returns declairation string for this class's constructor
    def get_declaration(dataModel, genClass, codeFun, rend)
      getStandardClassInfo(dataModel, genClass, codeFun, rend)

      rend.add("static void write(nlohmann::json& json, const " +
               @standardClassType + "& item);")
    end

    # Returns declairation string for this class's constructor
    def get_declaration_inline(dataModel, genClass, codeFun, rend)
      getStandardClassInfo(dataModel, genClass, codeFun, rend)

      rend.startFuction("static void write(nlohmann::json& json, const " +
                        @standardClassType + "& item)")
      codeStr << get_body(dataModel, genClass, codeFun, rend)
      rend.endFunction
    end

    #
    def getStandardClassInfo(dataModel, genClass, codeFun, rend)
      @standardClass = dataModel.findClass("standard")

      if (@standardClass.namespaceList != nil)
        ns = @standardClass.namespaceList.join("::") + "::"
      else
        ns = ""
      end

      @standardClassType = ns + Utils.instance.getStyledClassName(@standardClass.name)

      if (@standardClass != nil)
        genClass.addInclude(@standardClass.namespaceList.join("/"), Utils.instance.getStyledClassName(dataModel.name))
      end
    end

    def get_dependencies(dataModel, genClass, codeFun, rend)
      genClass.addInclude("", "json.hpp")
      getStandardClassInfo(dataModel, genClass, codeFun, rend)
    end

    def get_definition(dataModel, genClass, codeFun, rend)
      rend.add("/**")
      rend.add("* Writes this classes primitives to a json element")
      rend.add("*/")

      classDef = String.new
      classDef << Utils.instance.getTypeName(codeFun.returnValue) << " " <<
        Utils.instance.getStyledClassName(genClass.name) << " :: " << "write(nlohmann::json& json, const " +
                                                                      @standardClassType + "& item)"
      rend.startClass(classDef)

      get_body(dataModel, genClass, codeFun, rend)

      rend.endFunction
    end

    def get_body(dataModel, genClass, codeFun, rend)
      conDef = String.new
      varArray = Array.new
      dataModel.getAllVarsFor(varArray)

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          curVarName = Utils.instance.getStyledVariableName(var)
          curVarType = Utils.instance.getTypeName(var)
          curVarClass = Classes.findVarClass(var)
          isEnum = curVarClass != nil && curVarClass.ctype == "enum"

          if (Utils.instance.isPrimitive(var) || isEnum)
            if var.listType == nil
              rend.add('json["' + curVarName + '"] = item.' + curVarName + ";")
            else
              rend.add('json["' + curVarName + '"] = nlohmann::json::array();')
              rend.startBlock("for (auto const& val: item." + curVarName + ")")
              rend.add('json["' + curVarName + '"].push_back(val);')
              rend.endBlock
            end
          elsif (isEnum)
            rend.add('json["' + curVarName + '"] = (int)item.' + curVarName + ";")
          else
            if var.listType == nil
              rend.add(
                Utils.instance.getClassName(var) + 'JsonEngine::write(json["' + curVarName + '"]' + ", item." + curVarName + ");"
              )
            else
              rend.add("nlohmann::json " + curVarName + "Node;")
              rend.add()
              rend.startBlock("for (auto const& val: item." + curVarName + ")")
              rend.add("nlohmann::json newNode;")
              rend.add(Utils.instance.getClassName(var) + "JsonEngine::write(newNode, val);")
              rend.add(curVarName + "Node.push_back(newNode);")
              rend.endBlock
              rend.add('json["' + curVarName + '"] = ' + curVarName + "Node;")
            end
          end
        end
      end
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodNlohmannJsonWrite.new)
