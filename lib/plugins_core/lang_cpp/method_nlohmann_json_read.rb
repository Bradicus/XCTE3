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
    end

    # Returns declairation string for this class's constructor
    def get_declaration(cls, codeFun, codeBuilder)
      Utils.instance.getStandardClassInfo(cls)

      codeBuilder.add("static void read(const nlohmann::json& json, " +
                      cls.standardClassType + "& item);")
    end

    # Returns declairation string for this class's constructor
    def get_declaration_inline(cls, codeFun, codeBuilder)
      Utils.instance.getStandardClassInfo(cls)

      codeBuilder.startFuction("static void read(const nlohmann::json& json, " +
                               cls.standardClassType + "& item);")
      codeStr << get_body(cls, codeFun, codeBuilder)
      codeBuilder.endFunction
    end

    def get_dependencies(cls, codeFun, codeBuilder)
      cls.addInclude("", "json.hpp")
      Utils.instance.getStandardClassInfo(cls)

      for bc in cls.standardClass.baseClasses
        cls.addInclude("", Utils.instance.getDerivedClassPrefix(bc) + "JsonEngine.h")
      end

      # Add dependecies for all variables that aren't primitives, and their engines
      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          if (!Utils.instance.isPrimitive(var) && !Utils.instance.getTypeName(var).end_with?("Type"))
            #cls.addInclude(var.namespace, Utils.instance.getTypeName(var) )
            cls.addInclude(cls.namespaceList.join("/"), Utils.instance.getClassName(var) + "JsonEngine")
          end
        end
      end
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, codeFun, codeBuilder)
      codeBuilder.add("/**")
      codeBuilder.add("* Reads this classes primitives from a json element")
      codeBuilder.add("*/")

      Utils.instance.getStandardClassInfo(cls)

      classDef = String.new
      classDef << Utils.instance.getTypeName(codeFun.returnValue) << " " <<
        Utils.instance.getStyledClassName(cls.name) << " :: " << "read(const nlohmann::json& json, " +
                                                                 cls.standardClassType + "& item)"
      codeBuilder.startClass(classDef)

      get_body(cls, codeFun, codeBuilder)

      codeBuilder.endFunction
    end

    def get_body(cls, codeFun, codeBuilder)
      conDef = String.new
      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      codeBuilder.startBlock("if (json.is_null() == false)")

      for bc in cls.standardClass.baseClasses
        bClass = Classes.findClass("standard", bc.name)
        codeBuilder.add(Utils.instance.getDerivedClassPrefix(bc) + "JsonEngine::read(json, item);")
      end

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE && !var.isStatic
          curVarName = Utils.instance.getStyledVariableName(var)
          curVarType = Utils.instance.getTypeName(var)
          curVarClass = Classes.findVarClass(var)
          isEnum = curVarClass != nil && curVarClass.ctype == "enum"

          if (Utils.instance.isPrimitive(var) || isEnum)
            if var.listType == nil
              if !isEnum
                codeBuilder.add('if (json.contains("' + curVarName + '")) item.' + curVarName +
                                ' = json["' + curVarName + '"].get<' + Utils.instance.getTypeName(var) + ">();")
              else
                codeBuilder.add('if (json.contains("' + curVarName + '")) item.' + curVarName +
                                ' = json["' + curVarName + '"].get<' + Utils.instance.getTypeName(var) + ">();")
              end
            else
              codeBuilder.add("item." + curVarName + ".clear();")
              codeBuilder.startBlock('for (auto child : json["' + curVarName + '"])')
              codeBuilder.add("item." + curVarName + ".push_back(child.get<" + Utils.instance.getBaseTypeName(var) + ">());")
              codeBuilder.endBlock
            end
          else
            if var.listType == nil
              codeBuilder.add(
                'if (json.contains("' + curVarName + '")) ' + Utils.instance.getClassName(var) + "JsonEngine::read(" +
                  'json["' + curVarName + '"], item.' + curVarName + ");"
              )
            else
              codeBuilder.startBlock('if (json.contains("' + curVarName + '"))')

              codeBuilder.startBlock('for (auto aJson : json["' + curVarName + '"])')

              if (var.isSharedPointer)
                codeBuilder.add(Utils.instance.getSingleItemTypeName(var) + " newVar(new " + Utils.instance.getBaseTypeName(var) + "());")
                codeBuilder.add(Utils.instance.getClassName(var) + "JsonEngine::read(aJson, *newVar);")
              else
                codeBuilder.add(Utils.instance.getSingleItemTypeName(var) + " newVar;")
                codeBuilder.add(Utils.instance.getClassName(var) + "JsonEngine::read(aJson, newVar);")
              end

              codeBuilder.add("item." + curVarName + ".push_back(newVar);")

              codeBuilder.endBlock
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
