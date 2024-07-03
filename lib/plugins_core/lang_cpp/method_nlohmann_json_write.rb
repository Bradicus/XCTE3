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
  class MethodNlohmannJsonWrite < XCTEPlugin
    def initialize
      @name = "method_nlohmann_json_write"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's constructor
    def render_declaration(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec

      Utils.instance.getStandardClassInfo(cls)

      bld.add("static void write(nlohmann::json& json, const " +
              cls.standard_class_type + "& item);")
    end

    # Returns declairation string for this class's constructor
    def render_declaration_inline(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec

      Utils.instance.getStandardClassInfo(cls)

      bld.startFuction("static void write(nlohmann::json& json, const " +
                       cls.standard_class_type + "& item)")
      get_body(fp_params)
      bld.endFunction
    end

    def process_dependencies(cls, _codeFun)
      cls.addInclude("", "json.hpp")
      Utils.instance.getStandardClassInfo(cls)

      for bc in cls.standard_class.base_classes
        bc_sap = Utils.instance.get_plugin_and_spec_for_ref(cls, bc)
        if bc_sap.valid?
          cls.addInclude("", Utils.instance.get_derived_class_prefix(bc) + "JsonEngine.h")
        else
          cls.addInclude("", Utils.instance.get_derived_class_prefix(bc) + "JsonEngine.h")
        end
      end
    end

    def render_function(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      bld.add("/**")
      bld.add("* Writes this classes primitives to a json element")
      bld.add("*/")

      Utils.instance.getStandardClassInfo(cls)

      classDef = String.new
      classDef << Utils.instance.get_type_name(fun.returnValue) << " " <<
        Utils.instance.style_as_class(cls.get_u_name) << "JsonEngine :: " << "write(nlohmann::json& json, const " +
                                                                             cls.standard_class_type + "& item)"
      bld.start_class(classDef)

      get_body(fp_params)

      bld.endFunction
    end

    def get_body(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      conDef = String.new

      for bc in cls.standard_class.base_classes
        bc_sap = Utils.instance.get_plugin_and_spec_for_ref(cls, bc)
        if bc_sap.valid?
          bld.add(Utils.instance.get_derived_class_prefix(bc_sap.spec) + "JsonEngine::write(json, item);")
        else
          bld.add(Utils.instance.get_derived_class_prefix(bc) + "JsonEngine::write(json, item);")
        end
      end

      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.isStatic
          curVarName = Utils.instance.get_styled_variable_name(var)
          curVarType = Utils.instance.get_type_name(var)
          curVarClass = ClassModelManager.findVarClass(var)
          isEnum = !curVarClass.nil? && curVarClass.plug_name == "enum"

          if Utils.instance.is_primitive(var) || isEnum
            if !var.isList
              if var.getUType.downcase == "string"
                bld.add("if (item." + curVarName + '.size() > 0) json["' + curVarName + '"] = item.' + curVarName + ";")
              else
                bld.add('json["' + curVarName + '"] = item.' + curVarName + ";")
              end
            else
              bld.add('json["' + curVarName + '"] = nlohmann::json::array();')
              bld.start_block("for (auto const& val: item." + curVarName + ")")
              bld.add('json["' + curVarName + '"].push_back(val);')
              bld.end_block
            end
          elsif isEnum
            bld.add('json["' + curVarName + '"] = (int)item.' + curVarName + ";")
          elsif !var.isList
            bld.add(
              Utils.instance.get_class_name(var) + 'JsonEngine::write(json["' + curVarName + '"]' + ", item." + curVarName + ");"
            )
          else
            bld.add("nlohmann::json " + curVarName + "Node;")
            bld.add
            bld.start_block("for (auto const& val: item." + curVarName + ")")
            bld.add("nlohmann::json newNode;")
            if var.isPointer(1)
              bld.add(Utils.instance.get_class_name(var) + "JsonEngine::write(newNode, *val);")
            else
              bld.add(Utils.instance.get_class_name(var) + "JsonEngine::write(newNode, val);")
            end
            bld.add(curVarName + "Node.push_back(newNode);")
            bld.end_block
            bld.add('json["' + curVarName + '"] = ' + curVarName + "Node;")
          end
        end
      }))
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodNlohmannJsonWrite.new)
