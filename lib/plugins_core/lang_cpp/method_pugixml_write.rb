##

#
# Copyright (C) 2017 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'x_c_t_e_plugin'
require 'plugins_core/lang_cpp/x_c_t_e_cpp'

module XCTECpp
  class MethodPugiXmlWrite < XCTEPlugin
    def initialize
      @name = 'method_pugixml_write'
      @language = 'cpp'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's constructor
    def get_declaration(cls, bld, _codeFun)
      bld.add('void write(pugi::xml_node node, ' +
              Utils.instance.style_as_class(cls.name) + '& item);')
    end

    # Returns declairation string for this class's constructor
    def get_declaration_inline(cls, bld, codeFun)
      bld.startFuction('void write(pugi::xml_node node, ' +
                       Utils.instance.style_as_class(cls.name) + '& item);')
      codeStr << get_body(cls, bld, codeFun)
      bld.endFunction
    end

    def process_dependencies(cls, _bld, _codeFun)
      cls.addInclude('', 'pugixml.hpp')
    end

    # Returns definition string for this class's constructor
    def render_function(cls, bld, codeFun)
      bld.add('/**')
      bld.add("* Write this class' data to an xml element")
      bld.add('*/')

      classDef = String.new
      classDef << Utils.instance.get_type_name(codeFun.returnValue) << ' ' <<
        Utils.instance.style_as_class(cls.name) << ' :: ' << 'write(pugi::xml_node node, ' +
                                                                    Utils.instance.style_as_class(cls.name) + '& item)'
      bld.start_class(classDef)

      get_body(cls, bld, codeFun)

      bld.endFunction
    end

    def get_body(cls, bld, _codeFun)
      conDef = String.new

      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        styledVarName = Utils.instance.get_styled_variable_name(var)

        if Utils.instance.is_primitive(var)
          if !var.isList
            bld.add('node.append_attribute("' + styledVarName + '").set_value(' + styledVarName + ');')
          else
            bld.add('pugi::xml_node childNode = node.append_child("' + styledVarName + '");')
            bld.start_block('for (auto& listItem: item.' + styledVarName + ')')
            bld.add('pugi::xml_node valueNode = childNode.append_child("val");')
            bld.add('valueNode.set_value(listItem);')
            bld.end_block
          end
        elsif !var.isList
          bld.add(
            Utils.instance.get_type_name(var) + 'JsonEngine::loadFromJson(' +
            Utils.instance.get_styled_variable_name(var) +
              '(json["' + Utils.instance.get_styled_variable_name(var) + '"], ' + Utils.instance.get_styled_variable_name(var) + ');'
          )
        else
          bld.start_block('for (auto aJson : json["' + Utils.instance.get_styled_variable_name(var) + '"])')
          if !var.isList
            bld.add(Utils.instance.get_type_name(var) + 'JsonEngine::loadFromJson(aJson, item);')
          else
            bld.add(Utils.instance.get_type_name(var) + ' newVar;')
            bld.add(Utils.instance.get_type_name(var) + 'JsonEngine::loadFromJson(aJson, item);')
            bld.add(Utils.instance.get_styled_variable_name(var) + '.push_back(newVar);')
          end
          bld.end_block
        end
      }))
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodPugiXmlWrite.new)
