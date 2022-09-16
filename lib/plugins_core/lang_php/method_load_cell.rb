##

# 
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a constructor for a class
 
require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_php/x_c_t_e_php.rb'

class XCTEPhp::MethodLoadCell < XCTEPlugin
  
  def initialize
    @name = "method_load_cell"
    @language = "php"
    @category = XCTEPlugin::CAT_METHOD
  end
  
  # Returns definition string for this class's constructor
  def get_definition(codeClass, cfg, outCode)
    outCode.indent

    outCode.add("/**")
    outCode.add("* Loads an element of data into this set of data")
    outCode.add("*/")

    outCode.add("public function loadCell($cellString, $errorList, $curRowIndex, $curCellIndex)")
    outCode.add("{");

    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    outCode.add("    if (isset($cellString) && strlen($cellString) > 0)")
    outCode.add("    {")
    outCode.add("        switch($curCellIndex)")
    outCode.add("        {")

    cellIndex = 0;

    for var in varArray

      if var.elementId == CodeElem::ELEM_VARIABLE

        outCode.add("            case " << cellIndex.to_s << ": $this->dataSet['" << var.name << "'] = ")
        
        if var.vtype == "String"
          codeStr.add("$cellString;")
        elsif (var.vtype == "GBIdCode")
          codeStr.add("new " << codeClass.name << "($cellString);")
        else
          codeStr.add("$cellString;")
        end

        codeStr.add(" break;")

        if var.comment != nil
          codeStr.add("\t// " << var.comment)
        end

        codeStr.add

        cellIndex += 1

      elsif var.elementId == CodeElem::ELEM_FORMAT
        codeStr.add(var.formatText)
      end
    end

    outCode.iadd(2,     "}")
    outCode.iadd(1, "}")

    outCode.add("}")
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEPhp::MethodLoadCell.new)
