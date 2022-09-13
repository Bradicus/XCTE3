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
  class MethodPugiXmlWrite < XCTEPlugin
    def initialize
      @name = "method_pugixml_write"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's constructor
    def get_declaration(cls, codeFun, codeBuilder)
      codeBuilder.add("void write(pugi::xml_node node, " +
                      Utils.instance.getStyledClassName(cls.name) + "& item);")
    end

    # Returns declairation string for this class's constructor
    def get_declaration_inline(cls, codeFun, codeBuilder)
      codeBuilder.startFuction("void write(pugi::xml_node node, " +
                               Utils.instance.getStyledClassName(cls.name) + "& item);")
      codeStr << get_body(cls, codeFun, codeBuilder)
      codeBuilder.endFunction
    end

    def process_dependencies(cls, codeFun, codeBuilder)
      cls.addInclude("", "pugixml.hpp")
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, codeFun, codeBuilder)
      codeBuilder.add("/**")
      codeBuilder.add("* Write this class' data to an xml element")
      codeBuilder.add("*/")

      classDef = String.new
      classDef << Utils.instance.getTypeName(codeFun.returnValue) << " " <<
        Utils.instance.getStyledClassName(cls.name) << " :: " << "write(pugi::xml_node node, " +
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

          if (Utils.instance.isPrimitive(var))
            if var.listType == nil
              codeBuilder.add('node.append_attribute("' + styledVarName + '").set_value(' + styledVarName + ");")
            else
              codeBuilder.add('pugi::xml_node childNode = node.append_child("' + styledVarName + '");')
              codeBuilder.startBlock("for (auto& listItem: item." + styledVarName + ")")
              codeBuilder.add('pugi::xml_node valueNode = childNode.append_child("val");')
              codeBuilder.add("valueNode.set_value(listItem);")
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
XCTEPlugin::registerPlugin(XCTECpp::MethodPugiXmlWrite.new)
