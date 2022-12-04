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
    def get_declaration(cls, bld, codeFun)
      bld.add("void load(pugi::xml_node node, " +
              Utils.instance.getStyledClassName(cls.name) + "& item);")
    end

    # Returns declairation string for this class's constructor
    def get_declaration_inline(cls, bld, codeFun)
      bld.startFuction("void load(pugi::xml_node node, " +
                       Utils.instance.getStyledClassName(cls.name) + "& item);")
      codeStr << get_body(cls, bld, codeFun)
      bld.endFunction
    end

    def process_dependencies(cls, bld, codeFun)
      cls.addInclude("", "pugixml.hpp")
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld, codeFun)
      bld.add("/**")
      bld.add("* Load this classes primitives from a xml element")
      bld.add("*/")

      classDef = String.new
      classDef << Utils.instance.getTypeName(codeFun.returnValue) << " " <<
        Utils.instance.getStyledClassName(cls.name) << " :: " << "read(pugi::xml_node node, " +
                                                                 Utils.instance.getStyledClassName(cls.name) + "& item)"
      bld.startClass(classDef)

      get_body(cls, bld, codeFun)

      bld.endFunction
    end

    def get_body(cls, bld, codeFun)
      conDef = String.new

      # Process variables
      Utils.instance.eachVar(UtilsEachVarParams.new(cls, bld, true, lambda { |var|
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
            bld.add(styledVarName + " = item.child(" + styledVarName + ")." + pugiCast + ";")
          else
            bld.startBlock('for (pugi::xml_node pNode = item.child("' + styledVarName + '"); pNode; pNode = pNode.next_sibling("' + styledVarName + '")')
            bld.add(styledVarName + ".push_back(pNode." + pugiCast + ");")
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
      }))
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodPugiXmlRead.new)
