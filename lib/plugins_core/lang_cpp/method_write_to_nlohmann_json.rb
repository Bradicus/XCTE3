##

# 
# Copyright (C) 2017 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a constructor for a class
 
require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'

module XCTECpp
class MethodWriteToNlohmannJson < XCTEPlugin
  
  def initialize
    @name = "method_write_to_nlohmann_json"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end
  
  # Returns declairation string for this class's constructor
  def get_declaration(dataModel, genClass, codeFun, rend)
    rend.add("void writeToJson(nlohmann::json& j) const;")
  end

  # Returns declairation string for this class's constructor
  def get_declaration_inline(dataModel, genClass, codeFun, rend)
    rend.startFuction("void writeToJson(nlohmann::json& j) const")
    codeStr << get_body(dataModel, genClass, codeFun, rend)
    rend.endFunction
  end

  def get_dependencies(dataModel, genClass, codeFun, rend)
    genClass.addInclude('', 'json.hpp')
  end
  
  # Returns definition string for this class's constructor
  def get_definition(dataModel, genClass, codeFun, rend)
    rend.add("/**")
    rend.add("* Writes this classes primitives to a json element")
    rend.add("*/")
      
    classDef = String.new  
    classDef << Utils.instance.getTypeName(codeFun.returnValue) << " " << 
      Utils.instance.getStyledClassName(genClass.name) << " :: " << "writeToJson(nlohmann::json& j) const"
    rend.startClass(classDef)

    get_body(dataModel, genClass, codeFun, rend)
        
    rend.endFunction
  end

  def get_body(dataModel, genClass, codeFun, rend)
    conDef = String.new
    varArray = Array.new
    dataModel.getAllVarsFor(varArray);

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        curVarName = Utils.instance.getStyledVariableName(var);

        if (Utils.instance.isPrimitive(var))
          if var.listType == nil
            rend.add('j["' + curVarName + '"] = ' + curVarName + ';')
          else
            rend.startBlock('for (auto const& val: ' + curVarName + ')')
            rend.add('j["' + curVarName + '"].push_back(val);')
            rend.endBlock
          end
        else
          if var.listType == nil            
            rend.add(curVarName + '.writeToJson(j["' + curVarName + '"]' + ');')
          else
            rend.startBlock('for (auto const& val: ' + curVarName + ')')
            rend.add('nlohmann::json newNode;')
            rend.add('val.writeToJson(newNode);')
            rend.add('j["' + curVarName + '"] = newNode;')
            rend.endBlock
          end
        end

      end
    end
  end
  
end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodWriteToNlohmannJson.new)
