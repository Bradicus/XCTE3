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
    def get_declaration(cls, codeFun, bld)
      Utils.instance.getStandardClassInfo(cls)

      bld.add("static void read(const nlohmann::json& json, " +
              cls.standardClassType + "& item);")
    end

    # Returns declairation string for this class's constructor
    def get_declaration_inline(cls, codeFun, bld)
      Utils.instance.getStandardClassInfo(cls)

      bld.startFuction("static void read(const nlohmann::json& json, " +
                       cls.standardClassType + "& item);")
      codeStr << get_body(cls, codeFun, bld)
      bld.endFunction
    end

    def process_dependencies(cls, codeFun, bld)
      cls.addInclude("", "json.hpp")
      Utils.instance.getStandardClassInfo(cls)

      for bc in cls.standardClass.baseClasses
        cls.addInclude("", Utils.instance.getDerivedClassPrefix(bc) + "JsonEngine.h")
      end

      # Process variables
      Utils.instance.eachVar(UtilsEachVarParams.new(cls, nil, true, lambda { |var|
        if (!Utils.instance.isPrimitive(var) && !Utils.instance.getTypeName(var).end_with?("Type"))
          #cls.addInclude(var.namespace, Utils.instance.getTypeName(var) )
          cls.addInclude(cls.namespace.get("/"), Utils.instance.getClassName(var) + "JsonEngine")
        end
      }))
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, codeFun, bld)
      bld.add("/**")
      bld.add("* Reads this classes primitives from a json element")
      bld.add("*/")

      Utils.instance.getStandardClassInfo(cls)

      classDef = String.new
      classDef << Utils.instance.getTypeName(codeFun.returnValue) << " " <<
        Utils.instance.getStyledClassName(cls.name) << " :: " << "read(const nlohmann::json& json, " +
                                                                 cls.standardClassType + "& item)"
      bld.startClass(classDef)

      get_body(cls, codeFun, bld)

      bld.endFunction
    end

    def get_body(cls, codeFun, bld)
      conDef = String.new

      bld.startBlock("if (json.is_null() == false)")

      for bc in cls.standardClass.baseClasses
        bClass = Classes.findClass("standard", bc.name)
        bld.add(Utils.instance.getDerivedClassPrefix(bc) + "JsonEngine::read(json, item);")
      end

      # Process variables
      Utils.instance.eachVar(UtilsEachVarParams.new(cls, bld, true, lambda { |var|
        if !var.isStatic
          curVarName = Utils.instance.getStyledVariableName(var)
          curVarType = Utils.instance.getTypeName(var)
          curVarClass = Classes.findVarClass(var)
          isEnum = curVarClass != nil && curVarClass.ctype == "enum"

          if (Utils.instance.isPrimitive(var) || isEnum)
            if var.listType == nil
              if !isEnum
                bld.add('if (json.contains("' + curVarName + '")) item.' + curVarName +
                        ' = json["' + curVarName + '"].get<' + Utils.instance.getTypeName(var) + ">();")
              else
                bld.add('if (json.contains("' + curVarName + '")) item.' + curVarName +
                        ' = json["' + curVarName + '"].get<' + Utils.instance.getTypeName(var) + ">();")
              end
            else
              bld.add("item." + curVarName + ".clear();")
              bld.startBlock('for (auto child : json["' + curVarName + '"])')
              bld.add("item." + curVarName + ".push_back(child.get<" + Utils.instance.getBaseTypeName(var) + ">());")
              bld.endBlock
            end
          else
            if var.listType == nil
              bld.add(
                'if (json.contains("' + curVarName + '")) ' + Utils.instance.getClassName(var) + "JsonEngine::read(" +
                  'json["' + curVarName + '"], item.' + curVarName + ");"
              )
            else
              bld.startBlock('if (json.contains("' + curVarName + '"))')

              bld.startBlock('for (auto aJson : json["' + curVarName + '"])')

              if (var.isSharedPointer)
                bld.add(Utils.instance.getSingleItemTypeName(var) + " newVar(new " + Utils.instance.getBaseTypeName(var) + "());")
                bld.add(Utils.instance.getClassName(var) + "JsonEngine::read(aJson, *newVar);")
              else
                bld.add(Utils.instance.getSingleItemTypeName(var) + " newVar;")
                bld.add(Utils.instance.getClassName(var) + "JsonEngine::read(aJson, newVar);")
              end

              bld.add("item." + curVarName + ".push_back(newVar);")

              bld.endBlock
              bld.endBlock
            end
          end
        end
      }))

      bld.endBlock
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodNlohmannJsonRead.new)
