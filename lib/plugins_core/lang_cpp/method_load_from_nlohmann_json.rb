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
class MethodLoadFromNlohmannJson < XCTEPlugin
  
  def initialize
    @name = "method_load_from_nlohmann_json"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end
  
  # Returns declairation string for this class's constructor
  def get_declaration(dataModel, genClass, codeFun, codeBuilder)
    codeBuilder.add("void loadFromJson(nlohmann::json json);")
  end

  # Returns declairation string for this class's constructor
  def get_declaration_inline(dataModel, genClass, codeFun, codeBuilder)
    codeBuilder.startFuction("void loadFromJson(nlohmann::json json)")
    codeStr << get_body(dataModel, genClass, codeFun, codeBuilder)
    codeBuilder.endFunction
  end

  def get_dependencies(dataModel, genClass, codeFun, codeBuilder)
    genClass.addInclude('', 'json.hpp')
  end
  
  # Returns definition string for this class's constructor
  def get_definition(dataModel, genClass, codeFun, codeBuilder)
    codeBuilder.add("/**")
    codeBuilder.add("* Load this classes primitives from a json element")
    codeBuilder.add("*/")
      
    classDef = String.new  
    classDef << Utils.instance.getTypeName(codeFun.returnValue) << " " << 
      Utils.instance.getStyledClassName(genClass.name) << " :: " << "loadFromJson(nlohmann::json json)"
    codeBuilder.startClass(classDef)

    get_body(dataModel, genClass, codeFun, codeBuilder)
        
    codeBuilder.endFunction
  end

  def get_body(dataModel, genClass, codeFun, codeBuilder)
    conDef = String.new
    varArray = Array.new
    dataModel.getAllVarsFor(varArray);

    codeBuilder.startBlock('if (json.is_null() == false)')

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if (Utils.instance.isPrimitive(var))
          if var.listType == nil
            codeBuilder.add(Utils.instance.getStyledVariableName(var) + 
              ' = json["' + Utils.instance.getStyledVariableName(var) + '"].get<' + Utils.instance.getTypeName(var) + '>();')
          else            
            codeBuilder.startBlock('for (auto item : json["' + Utils.instance.getStyledVariableName(var) + '"])')
            codeBuilder.add(Utils.instance.getStyledVariableName(var) + '.push_back(item.get<' + Utils.instance.getTypeName(var) + '>());')
            codeBuilder.endBlock
          end
        else
          if var.listType == nil
            codeBuilder.add(Utils.instance.getStyledVariableName(var) + 
                '.loadFromJson(json["' + Utils.instance.getStyledVariableName(var) + '"]);')
          else
            codeBuilder.startBlock('for (auto item : json["' + Utils.instance.getStyledVariableName(var) + '"])')
            if (var.listType == nil)
              codeBuilder.add(Utils.instance.getStyledVariableName(var) + '.loadFromJson(item);')
            else
              codeBuilder.add(Utils.instance.getTypeName(var) + ' newVar;')
              codeBuilder.add('newVar.loadFromJson(item);')
              codeBuilder.add(Utils.instance.getStyledVariableName(var) + '.push_back(newVar);')
            end
            codeBuilder.endBlock
          end
        end
      end
    end

    codeBuilder.endBlock
  end
  
end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodLoadFromNlohmannJson.new)
