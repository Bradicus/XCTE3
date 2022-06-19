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
  class MethodPugiXmlRead < XCTEPlugin
    def initialize
      @name = "method_pugixml_read"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's constructor
    def get_declaration(cls, codeFun, codeBuilder)
      codeBuilder.add("void load(pugi::xml_node node, " +
                      Utils.instance.getStyledClassName(cls.name) + "& item);")
    end

    # Returns declairation string for this class's constructor
    def get_declaration_inline(cls, codeFun, codeBuilder)
      codeBuilder.startFuction("void load(pugi::xml_node node, " +
                               Utils.instance.getStyledClassName(cls.name) + "& item);")
      codeStr << get_body(cls, codeFun, codeBuilder)
      codeBuilder.endFunction
    end

    def get_dependencies(cls, codeFun, codeBuilder)
      cls.addInclude("", "pugixml.hpp")
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, codeFun, codeBuilder)
      codeBuilder.add("/**")
      codeBuilder.add("* Load this classes primitives from a xml element")
      codeBuilder.add("*/")

      classDef = String.new
      classDef << Utils.instance.getTypeName(codeFun.returnValue) << " " <<
        Utils.instance.getStyledClassName(cls.name) << " :: " << "read(pugi::xml_node node, " +
                                                                 Utils.instance.getStyledClassName(cls.name) + "& item)"
      codeBuilder.startClass(classDef)

      get_body(cls, codeFun, codeBuilder)

      codeBuilder.endFunction
    end

    def get_body(cls, codeFun, codeBuilder)
      conDef = String.new
      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          styledVarName = Utils.instance.getStyledVariableName(var)

          pugiCast = "to_string()"
          if (var.vtype.start_with? "Int")
            pugiCast = "to_int()"
          end
          if (var.vtype.start_with? "Float")
            pugiCast = "to_float()"
          end

          if (Utils.instance.isPrimitive(var))
            if var.listType == nil
              codeBuilder.add(styledVarName + " = item.child(" + styledVarName + ")." + pugiCast + ";")
            else
              codeBuilder.startBlock('for (pugi::xml_node pNode = item.child("' + styledVarName + '"); pNode; pNode = pNode.next_sibling("' + styledVarName + '")')
              codeBuilder.add(styledVarName + ".push_back(pNode." + pugiCast + ");")
              codeBuilder.endBlock
            end
          else
            if var.listType == nil
              codeBuilder.add(
                Utils.instance.getTypeName(var) + "JsonEngine::loadFromJson(" +
                Utils.instance.getStyledVariableName(var) +
                  '(json["' + Utils.instance.getStyledVariableName(var) + '"], ' + Utils.instance.getStyledVariableName(var) + ");"
              )
            else
              codeBuilder.startBlock('for (auto aJson : json["' + Utils.instance.getStyledVariableName(var) + '"])')
              if (var.listType == nil)
                codeBuilder.add(Utils.instance.getTypeName(var) + "JsonEngine::loadFromJson(aJson, item);")
              else
                codeBuilder.add(Utils.instance.getTypeName(var) + " newVar;")
                codeBuilder.add(Utils.instance.getTypeName(var) + "JsonEngine::loadFromJson(aJson, item);")
                codeBuilder.add(Utils.instance.getStyledVariableName(var) + ".push_back(newVar);")
              end
              codeBuilder.endBlock
            end
          end
        end
      end
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodPugiXmlRead.new)
