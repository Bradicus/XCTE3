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
    def get_declaration(cls, codeFun, bld)
      Utils.instance.getStandardClassInfo(cls)

      bld.add("static void write(nlohmann::json& json, const " +
              cls.standardClassType + "& item);")
    end

    # Returns declairation string for this class's constructor
    def get_declaration_inline(cls)
      Utils.instance.getStandardClassInfo(cls)

      bld.startFuction("static void write(nlohmann::json& json, const " +
                       cls.standardClassType + "& item)")
      codeStr << get_body(cls)
      bld.endFunction
    end

    def process_dependencies(cls, codeFun, bld)
      cls.addInclude("", "json.hpp")
      Utils.instance.getStandardClassInfo(cls)

      for bc in cls.standardClass.baseClasses
        cls.addInclude("", Utils.instance.getDerivedClassPrefix(bc) + "JsonEngine.h")
      end
    end

    def get_definition(cls, codeFun, bld)
      bld.add("/**")
      bld.add("* Writes this classes primitives to a json element")
      bld.add("*/")

      classDef = String.new
      classDef << Utils.instance.getTypeName(codeFun.returnValue) << " " <<
        Utils.instance.getStyledClassName(cls.name) << " :: " << "write(nlohmann::json& json, const " +
                                                                 cls.standardClassType + "& item)"
      bld.startClass(classDef)

      get_body(cls, codeFun, bld)

      bld.endFunction
    end

    def get_body(cls, codeFun, bld)
      conDef = String.new

      for bc in cls.standardClass.baseClasses
        bld.add(Utils.instance.getDerivedClassPrefix(bc) + "JsonEngine::write(json, item);")
      end

      # Process variables
      Utils.instance.eachVar(cls, bld, true, lambda { |var|
        if !var.isStatic
          curVarName = Utils.instance.getStyledVariableName(var)
          curVarType = Utils.instance.getTypeName(var)
          curVarClass = Classes.findVarClass(var)
          isEnum = curVarClass != nil && curVarClass.ctype == "enum"

          if (Utils.instance.isPrimitive(var) || isEnum)
            if var.listType == nil
              if (var.getUType().downcase == "string")
                bld.add("if (item." + curVarName + '.size() > 0) json["' + curVarName + '"] = item.' + curVarName + ";")
              else
                bld.add('json["' + curVarName + '"] = item.' + curVarName + ";")
              end
            else
              bld.add('json["' + curVarName + '"] = nlohmann::json::array();')
              bld.startBlock("for (auto const& val: item." + curVarName + ")")
              bld.add('json["' + curVarName + '"].push_back(val);')
              bld.endBlock
            end
          elsif (isEnum)
            bld.add('json["' + curVarName + '"] = (int)item.' + curVarName + ";")
          else
            if var.listType == nil
              bld.add(
                Utils.instance.getClassName(var) + 'JsonEngine::write(json["' + curVarName + '"]' + ", item." + curVarName + ");"
              )
            else
              bld.add("nlohmann::json " + curVarName + "Node;")
              bld.add()
              bld.startBlock("for (auto const& val: item." + curVarName + ")")
              bld.add("nlohmann::json newNode;")
              if (var.isSharedPointer)
                bld.add(Utils.instance.getClassName(var) + "JsonEngine::write(newNode, *val);")
              else
                bld.add(Utils.instance.getClassName(var) + "JsonEngine::write(newNode, val);")
              end
              bld.add(curVarName + "Node.push_back(newNode);")
              bld.endBlock
              bld.add('json["' + curVarName + '"] = ' + curVarName + "Node;")
            end
          end
        end
      })
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodNlohmannJsonWrite.new)
