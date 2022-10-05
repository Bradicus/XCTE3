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
    end

    # Returns declairation string for this class's constructor
    def get_declaration(cls, codeFun, rend)
      Utils.instance.getStandardClassInfo(cls)

      rend.add("static void write(nlohmann::json& json, const " +
               cls.standardClassType + "& item);")
    end

    # Returns declairation string for this class's constructor
    def get_declaration_inline(cls)
      Utils.instance.getStandardClassInfo(cls)

      rend.startFuction("static void write(nlohmann::json& json, const " +
                        cls.standardClassType + "& item)")
      codeStr << get_body(cls)
      rend.endFunction
    end

    def process_dependencies(cls, codeFun, rend)
      cls.addInclude("", "json.hpp")
      Utils.instance.getStandardClassInfo(cls)

      for bc in cls.standardClass.baseClasses
        cls.addInclude("", Utils.instance.getDerivedClassPrefix(bc) + "JsonEngine.h")
      end
    end

    def get_definition(cls, codeFun, rend)
      rend.add("/**")
      rend.add("* Writes this classes primitives to a json element")
      rend.add("*/")

      classDef = String.new
      classDef << Utils.instance.getTypeName(codeFun.returnValue) << " " <<
        Utils.instance.getStyledClassName(cls.name) << " :: " << "write(nlohmann::json& json, const " +
                                                                 cls.standardClassType + "& item)"
      rend.startClass(classDef)

      get_body(cls, codeFun, rend)

      rend.endFunction
    end

    def get_body(cls, codeFun, rend)
      conDef = String.new
      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      for bc in cls.standardClass.baseClasses
        rend.add(Utils.instance.getDerivedClassPrefix(bc) + "JsonEngine::write(json, item);")
      end

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE && !var.isStatic
          curVarName = Utils.instance.getStyledVariableName(var)
          curVarType = Utils.instance.getTypeName(var)
          curVarClass = Classes.findVarClass(var)
          isEnum = curVarClass != nil && curVarClass.ctype == "enum"

          if (Utils.instance.isPrimitive(var) || isEnum)
            if var.listType == nil
              if (var.getUType().downcase == "string")
                rend.add("if (item." + curVarName + '.size() > 0) json["' + curVarName + '"] = item.' + curVarName + ";")
              else
                rend.add('json["' + curVarName + '"] = item.' + curVarName + ";")
              end
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
              if (var.isSharedPointer)
                rend.add(Utils.instance.getClassName(var) + "JsonEngine::write(newNode, *val);")
              else
                rend.add(Utils.instance.getClassName(var) + "JsonEngine::write(newNode, val);")
              end
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
