##

#
# Copyright (C) 2017 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin"
require "plugins_core/lang_cpp/x_c_t_e_cpp"

module XCTECpp
  class MethodPugiXmlWrite < XCTEPlugin
    def initialize
      @name = "method_pugixml_write"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's constructor
    def render_declaration(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      Utils.instance.getStandardClassInfo(cls)
      bld.add("void write(pugi::xml_node node, " +
              Utils.instance.style_as_class(cls.model.name) + "& item);")
    end

    # Returns declairation string for this class's constructor
    def render_declaration_inline(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      std_class = PluginManager.find_class_plugin("cpp", "class_standard")

      bld.startFuction("void write(pugi::xml_node node, " + Utils.instance.style_as_class(cls.model.name) + "& item);")
      get_body(fp_params)
      bld.endFunction
    end

    def process_dependencies(cls, _bld, _codeFun)
      cls.addInclude("", "pugixml.hpp")
      cls.addInclude("", Utils.instance.style_as_class(cls.model.name) + ".h")
    end

    # Returns definition string for this class's constructor
    def render_function(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      bld.add("/**")
      bld.add("* Write this class' data to an xml element")
      bld.add("*/")

      classDef = String.new
      classDef << Utils.instance.get_type_name(fun.returnValue) << " " <<
        Utils.instance.style_as_class(cls.get_u_name) << " :: write(pugi::xml_node node, " << Utils.instance.style_as_class(cls.model.name) << "& item)"
      bld.start_class(classDef)

      get_body(fp_params)

      bld.endFunction
    end

    def get_body(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      conDef = String.new

      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        styledVarName = Utils.instance.get_styled_variable_name(var)
        varTypeName = Utils.instance.get_type_name(var)

        if Utils.instance.is_primitive(var)
          if !var.isList
            if (var.getUType().downcase == "string")
              bld.add('node.append_attribute("' + styledVarName + '").set_value(item.' + styledVarName + ".c_str());")
            else
              bld.add('node.append_attribute("' + styledVarName + '").set_value(item.' + styledVarName + ");")
            end
          else
            bld.add('pugi::xml_node childNode = node.append_child("' + styledVarName + '");')
            bld.start_block("for (auto& listItem: item." + styledVarName + ")")
            bld.add('pugi::xml_node valueNode = childNode.append_child("val");')
            bld.add("valueNode.set_value(listItem);")
            bld.end_block
          end
        elsif !var.isList
          bld.add(Utils.instance.get_class_name(var) + "PugiXmlEngine::write(" +
                  'node.append_child("' + styledVarName + '")' +
                  ", item." + styledVarName + ");")
        else
          if !var.isList
            bld.add(varTypeName + "PugiXmlEngine::write(pNode, item);")
          else
            bld.start_block("for (auto& listItem: item." + styledVarName + ")")
            bld.add(varTypeName + " newVar;")
            bld.add(Utils.instance.get_class_name(var) + "PugiXmlEngine::write(pNode, listItem);")
            bld.add("item." + styledVarName + ".push_back(newVar);")
          end
          bld.end_block
        end
      }))
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodPugiXmlWrite.new)
