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
  class MethodPugiXmlRead < XCTEPlugin
    def initialize
      @name = "method_pugixml_read"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
    end

    def process_dependencies(cls, _codeFun)
      cls.addInclude("", "pugixml.hpp")
      cls.addInclude("", Utils.instance.style_as_class(cls.model.name) + ".h")
    end

    # Returns declairation string for this class's constructor
    def render_declaration(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      Utils.instance.getStandardClassInfo(cls)
      bld.add("static void read(pugi::xml_node node, " +
              Utils.instance.style_as_class(cls.model.name) + "& item);")
    end

    # Returns declairation string for this class's constructor
    def render_declaration_inline(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      Utils.instance.getStandardClassInfo(cls)
      bld.startFuction("static void read(pugi::xml_node node, " +
                       Utils.instance.style_as_class(cls.model.name) + "& item);")
      codeStr << get_body(cls, bld, codeFun)
      bld.endFunction
    end

    # Returns definition string for this class's constructor
    def render_function(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      bld.add("/**")
      bld.add("* Load this classes primitives from a xml element")
      bld.add("*/")

      classDef = String.new
      classDef << Utils.instance.get_type_name(fun.returnValue) << " " <<
        Utils.instance.style_as_class(cls.get_u_name) << " :: read(pugi::xml_node node, " << Utils.instance.style_as_class(cls.model.name) << "& item)"
      bld.start_class(classDef)

      get_body(fp_params)

      bld.endFunction
    end

    def get_body(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        styledVarName = Utils.instance.get_styled_variable_name(var)
        curVarType = Utils.instance.get_type_name(var)
        curVarClass = ClassModelManager.findVarClass(var)

        pugiCast = "as_string()"
        pugiCast = "as_int()" if var.getUType().downcase.start_with? "int"
        pugiCast = "as_float()" if var.getUType().downcase.start_with? "float"

        if Utils.instance.is_primitive(var)
          if !var.isList
            bld.add("item." + styledVarName + ' = node.attribute("' + styledVarName + '").' + pugiCast + ";")
          else
            bld.start_block('for (pugi::xml_node pNode = node.child("' + styledVarName + '"); pNode; pNode = pNode.next_sibling("' + styledVarName + '"))')
            bld.add("item." + styledVarName + ".push_back(pNode.text()." + pugiCast + ");")
            bld.end_block
          end
        elsif !var.isList
          bld.add(
            Utils.instance.get_class_name(var) + "PugiXmlEngine::read(" +
            'node.child("' + Utils.instance.get_styled_variable_name(var) +
              '"), item.' + styledVarName + ");"
          )
        else
          bld.start_block('for (pugi::xml_node pNode = node.child("' + styledVarName + '"); pNode; pNode = pNode.next_sibling("' + styledVarName + '"))')
          if !var.isList
            bld.add(Utils.instance.get_class_name(var) + "PugiXmlEngine::read(node, pNode);")
          else
            bld.add(Utils.instance.get_single_item_type_name(var) + " newVar;")
            bld.add(Utils.instance.get_class_name(var) + "PugiXmlEngine::read(node, newVar);")
            bld.add("item." + Utils.instance.get_styled_variable_name(var) + ".push_back(newVar);")
          end
          bld.end_block
        end
      }))
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodPugiXmlRead.new)
