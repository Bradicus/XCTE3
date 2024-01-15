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
  class MethodNlohmannJsonWrite < XCTEPlugin
    def initialize
      @name = 'method_nlohmann_json_write'
      @language = 'cpp'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's constructor
    def get_declaration(cls, bld, _codeFun)
      Utils.instance.getStandardClassInfo(cls)

      bld.add('static void write(nlohmann::json& json, const ' +
              cls.standardClassType + '& item);')
    end

    # Returns declairation string for this class's constructor
    def get_declaration_inline(cls)
      Utils.instance.getStandardClassInfo(cls)

      bld.startFuction('static void write(nlohmann::json& json, const ' +
                       cls.standardClassType + '& item)')
      codeStr << get_body(cls)
      bld.endFunction
    end

    def process_dependencies(cls, _bld, _codeFun)
      cls.addInclude('', 'json.hpp')
      Utils.instance.getStandardClassInfo(cls)

      for bc in cls.standardClass.baseClasses
        cls.addInclude('', Utils.instance.getDerivedClassPrefix(bc) + 'JsonEngine.h')
      end
    end

    def get_definition(cls, bld, codeFun)
      bld.add('/**')
      bld.add('* Writes this classes primitives to a json element')
      bld.add('*/')

      classDef = String.new
      classDef << Utils.instance.get_type_name(codeFun.returnValue) << ' ' <<
        Utils.instance.get_styled_class_name(cls.name) << ' :: ' << 'write(nlohmann::json& json, const ' +
                                                                    cls.standardClassType + '& item)'
      bld.start_class(classDef)

      get_body(cls, bld, codeFun)

      bld.endFunction
    end

    def get_body(cls, bld, _codeFun)
      conDef = String.new

      for bc in cls.standardClass.baseClasses
        bld.add(Utils.instance.getDerivedClassPrefix(bc) + 'JsonEngine::write(json, item);')
      end

      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.isStatic
          curVarName = Utils.instance.get_styled_variable_name(var)
          curVarType = Utils.instance.get_type_name(var)
          curVarClass = ClassModelManager.findVarClass(var)
          isEnum = !curVarClass.nil? && curVarClass.plugName == 'enum'

          if Utils.instance.is_primitive(var) || isEnum
            if !var.isList
              if var.getUType.downcase == 'string'
                bld.add('if (item.' + curVarName + '.size() > 0) json["' + curVarName + '"] = item.' + curVarName + ';')
              else
                bld.add('json["' + curVarName + '"] = item.' + curVarName + ';')
              end
            else
              bld.add('json["' + curVarName + '"] = nlohmann::json::array();')
              bld.start_block('for (auto const& val: item.' + curVarName + ')')
              bld.add('json["' + curVarName + '"].push_back(val);')
              bld.end_block
            end
          elsif isEnum
            bld.add('json["' + curVarName + '"] = (int)item.' + curVarName + ';')
          elsif !var.isList
            bld.add(
              Utils.instance.get_class_name(var) + 'JsonEngine::write(json["' + curVarName + '"]' + ', item.' + curVarName + ');'
            )
          else
            bld.add('nlohmann::json ' + curVarName + 'Node;')
            bld.add
            bld.start_block('for (auto const& val: item.' + curVarName + ')')
            bld.add('nlohmann::json newNode;')
            if var.isPointer(1)
              bld.add(Utils.instance.get_class_name(var) + 'JsonEngine::write(newNode, *val);')
            else
              bld.add(Utils.instance.get_class_name(var) + 'JsonEngine::write(newNode, val);')
            end
            bld.add(curVarName + 'Node.push_back(newNode);')
            bld.end_block
            bld.add('json["' + curVarName + '"] = ' + curVarName + 'Node;')
          end
        end
      }))
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodNlohmannJsonWrite.new)
