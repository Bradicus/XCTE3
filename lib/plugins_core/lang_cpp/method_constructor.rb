##

# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a constructor for a class
 
require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_cpp/x_c_t_e_cpp.rb'

class XCTECpp::MethodConstructor < XCTEPlugin
  
  def initialize
    @name = "method_constructor"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end
  
  # Returns declairation string for this class's constructor
  def get_declaration(dataModel, genClass, funItem, codeBuilder)
    codeBuilder.add(genClass.name + "();")
  end

  # Returns declairation string for this class's constructor
  def get_declaration_inline(dataModel, genClass, funItem, codeBuilder)
    codeBuilder.startFuction(genClass.name + "()")
    codeStr << get_body(dataModel, genClass, funItem, hFile)
    codeBuilder.endFunction
  end

  def get_dependencies(dataModel, genClass, funItem, codeBuilder)
  end
  
  # Returns definition string for this class's constructor
  def get_definition(dataModel, genClass, funItem, codeBuilder)
    codeBuilder.add("/**")
    codeBuilder.add("* Constructor")
    codeBuilder.add("*/")
      
    classDef = String.new  
    classDef << genClass.name << " :: " << genClass.name << "()"
    codeBuilder.startClass(classDef)

    get_body(dataModel, genClass, funItem, codeBuilder)
        
    codeBuilder.endFunction
  end

  def get_body(dataModel, genClass, funItem, codeBuilder)
    conDef = String.new
    varArray = Array.new
    dataModel.getAllVarsFor(varArray);

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if var.defaultValue != nil
          codeBuilder.add(var.name << " = ")

          if var.vtype == "String"
            codeBuilder.sameLine("\"" << var.defaultValue << "\";")
          else
            codeBuilder.sameLine(var.defaultValue << ";")
          end

          if var.comment != nil
            codeBuilder.sameLine("\t// " << var.comment)
          end

          codeBuilder.add
        end
      end
    end
  end
  
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodConstructor.new)
