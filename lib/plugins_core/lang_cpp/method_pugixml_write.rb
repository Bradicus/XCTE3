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
    def get_declaration(cls, codeFun, bld)
      bld.add("void write(pugi::xml_node node, " +
              Utils.instance.getStyledClassName(cls.name) + "& item);")
    end

    # Returns declairation string for this class's constructor
    def get_declaration_inline(cls, codeFun, bld)
      bld.startFuction("void write(pugi::xml_node node, " +
                       Utils.instance.getStyledClassName(cls.name) + "& item);")
      codeStr << get_body(cls, codeFun, bld)
      bld.endFunction
    end

    def process_dependencies(cls, codeFun, bld)
      cls.addInclude("", "pugixml.hpp")
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, codeFun, bld)
      bld.add("/**")
      bld.add("* Write this class' data to an xml element")
      bld.add("*/")

      classDef = String.new
      classDef << Utils.instance.getTypeName(codeFun.returnValue) << " " <<
        Utils.instance.getStyledClassName(cls.name) << " :: " << "write(pugi::xml_node node, " +
                                                                 Utils.instance.getStyledClassName(cls.name) + "& item)"
      bld.startClass(classDef)

      get_body(cls, codeFun, bld)

      bld.endFunction
    end

    def get_body(cls, codeFun, bld)
      conDef = String.new

      # Process variables
      Utils.instance.eachVar(cls, bld, true, lambda { |var|
        styledVarName = Utils.instance.getStyledVariableName(var)

        if (Utils.instance.isPrimitive(var))
          if var.listType == nil
            bld.add('node.append_attribute("' + styledVarName + '").set_value(' + styledVarName + ");")
          else
            bld.add('pugi::xml_node childNode = node.append_child("' + styledVarName + '");')
            bld.startBlock("for (auto& listItem: item." + styledVarName + ")")
            bld.add('pugi::xml_node valueNode = childNode.append_child("val");')
            bld.add("valueNode.set_value(listItem);")
            bld.endBlock
          end
        else
          if var.listType == nil
            bld.add(
              Utils.instance.getTypeName(var) + "JsonEngine::loadFromJson(" +
              Utils.instance.getStyledVariableName(var) +
                '(json["' + Utils.instance.getStyledVariableName(var) + '"], ' + Utils.instance.getStyledVariableName(var) + ");"
            )
          else
            bld.startBlock('for (auto aJson : json["' + Utils.instance.getStyledVariableName(var) + '"])')
            if (var.listType == nil)
              bld.add(Utils.instance.getTypeName(var) + "JsonEngine::loadFromJson(aJson, item);")
            else
              bld.add(Utils.instance.getTypeName(var) + " newVar;")
              bld.add(Utils.instance.getTypeName(var) + "JsonEngine::loadFromJson(aJson, item);")
              bld.add(Utils.instance.getStyledVariableName(var) + ".push_back(newVar);")
            end
            bld.endBlock
          end
        end
      })
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodPugiXmlWrite.new)
