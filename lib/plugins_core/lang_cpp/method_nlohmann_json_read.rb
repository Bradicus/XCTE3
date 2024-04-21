##

#
# Copyright (C) 2017 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin"
require "plugins_core/lang_cpp/x_c_t_e_cpp"
require "managers/class_model_manager"

module XCTECpp
  class MethodNlohmannJsonRead < XCTEPlugin
    def initialize
      @name = "method_nlohmann_json_read"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's constructor
    def render_declaration(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec

      Utils.instance.getStandardClassInfo(cls)

      bld.add("static void read(const nlohmann::json& json, " +
              cls.standard_class_type + "& item);")
    end

    # Returns declairation string for this class's constructor
    def render_declaration_inline(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec

      Utils.instance.getStandardClassInfo(cls)

      bld.startFuction("static void read(const nlohmann::json& json, " +
                       cls.standard_class_type + "& item);")
      get_body(fp_params)
      bld.endFunction
    end

    def process_dependencies(cls, _bld, _codeFun)
      cls.addInclude("", "json.hpp")
      Utils.instance.getStandardClassInfo(cls)

      for bc in cls.standard_class.base_classes
        bc_sap = Utils.instance.get_plugin_and_spec_for_ref(cls, bc)
        if bc_sap.valid?
          cls.addInclude("", bc_sap.plugin.get_class_name(bc_sap.spec) + ".h")
        else
          cls.addInclude("", Utils.instance.style_as_class(bc.model_name + "JsonEngine.h"))
        end
      end

      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var) && !Utils.instance.get_type_name(var).end_with?("Type")
          # cls.addInclude(var.namespace, Utils.instance.get_type_name(var) )
          cls.addInclude(cls.namespace.get("/"), Utils.instance.get_class_name(var) + "JsonEngine")
        end
      }))
    end

    # Returns definition string for this class's constructor
    def render_function(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      bld.add("/**")
      bld.add("* Reads this classes primitives from a json element")
      bld.add("*/")

      Utils.instance.getStandardClassInfo(cls)

      classDef = String.new
      classDef << Utils.instance.get_type_name(fun.returnValue) << " " <<
        Utils.instance.style_as_class(cls.get_u_name) << "JsonEngine :: " << "read(const nlohmann::json& json, " +
                                                                             cls.standard_class_type + "& item)"
      bld.start_class(classDef)

      get_body(fp_params)

      bld.endFunction
    end

    def get_body(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec

      conDef = String.new

      bld.start_block("if (json.is_null() == false)")

      for bc in cls.standard_class.base_classes
        bc_sap = Utils.instance.get_plugin_and_spec_for_ref(cls, bc)
        if bc_sap.valid?
          bld.add(bc_sap.plugin.get_class_name(bc_sap.spec) + "JsonEngine::read(json, item);")
        else
          bld.add(Utils.instance.getDerivedClassPrefix(bc) + "JsonEngine::read(json, item);")
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
              if !isEnum
                bld.add('if (json.contains("' + curVarName + '")) item.' + curVarName +
                        ' = json["' + curVarName + '"].get<' + Utils.instance.get_type_name(var) + ">();")
              else
                bld.add('if (json.contains("' + curVarName + '")) item.' + curVarName +
                        ' = json["' + curVarName + '"].get<' + Utils.instance.get_type_name(var) + ">();")
              end
            else
              bld.add("item." + curVarName + ".clear();")
              bld.start_block('for (auto child : json["' + curVarName + '"])')
              bld.add("item." + curVarName + ".push_back(child.get<" + Utils.instance.get_base_type_name(var) + ">());")
              bld.end_block
            end
          elsif !var.isList
            bld.add(
              'if (json.contains("' + curVarName + '")) ' + Utils.instance.get_class_name(var) + "JsonEngine::read(" +
                'json["' + curVarName + '"], item.' + curVarName + ");"
            )
          else
            bld.start_block('if (json.contains("' + curVarName + '"))')

            bld.start_block('for (auto aJson : json["' + curVarName + '"])')

            if var.isPointer(1)
              bld.add(Utils.instance.get_single_item_type_name(var) + " newVar(new " + Utils.instance.get_base_type_name(var) + "());")
              bld.add(Utils.instance.get_class_name(var) + "JsonEngine::read(aJson, *newVar);")
            else
              bld.add(Utils.instance.get_single_item_type_name(var) + " newVar;")
              bld.add(Utils.instance.get_class_name(var) + "JsonEngine::read(aJson, newVar);")
            end

            bld.add("item." + curVarName + ".push_back(newVar);")

            bld.end_block
            bld.end_block
          end
        end
      }))

      bld.end_block
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodNlohmannJsonRead.new)
