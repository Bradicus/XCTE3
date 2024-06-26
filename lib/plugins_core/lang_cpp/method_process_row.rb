#
# To change this template, choose Tools | Templates
# and open the template in the editor.

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_cpp/x_c_t_e_cpp.rb"

class XCTECpp::MethodProcessRow < XCTEPlugin
  def initialize
    @name = "method_process_row"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's UGP read method
  def render_declaration(fp_params)
    bld = fp_params.bld
    cls = fp_params.cls_spec
    fun = fp_params.fun_spec

    bld.add "        void processRow(ug::datastruct::Table& table, ug::datastruct::TableRow& row);\n"
  end

  # Returns definition string for this class's UGP read method
  def render_function(fp_params)
    bld = fp_params.bld
    cls = fp_params.cls_spec
    fun = fp_params.fun_spec

    readDef = String.new
    indent = "    "

    readDef << "/**\n"
    readDef << "* Reads row information from a table in to this classes variables\n"
    readDef << "*/\n"
    readDef << "void " << codeClass.name << " :: processRow(ug::datastruct::Table& table, ug::datastruct::TableRow& row)\n"
    readDef << "{\n"

    readDef << indent << "int errCheck;\n"

    varArray = Array.new
    codeClass.getAllVarsFor(varArray)

    puts "Processing process_row method with var count: " + varArray.length.to_s

    for var in varArray
      if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
        if !var.isPointer && var.arrayElemCount == 0 # Not an array
          readDef << indent << "std::string " << var.name << "Field;\n"
        end
      end
    end

    readDef << "\n"

    for var in varArray
      if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
        if !var.isPointer && var.arrayElemCount == 0 # Not an array
          readDef << indent << "errCheck = table.getString(row, \"" << var.name << "\", " << var.name << "Field);\n"

          case (var.vtype)
          when "Int32"
            readDef << indent << var.name << " = atoi(" << var.name << "Field.c_str());\n"
          when "GBEffect"
            readDef << indent << var.name << ".loadEffectString(" << var.name << "Field);\n"
          when "MDataArray<GBEffect>"
            readDef << indent << var.name << " = GBEffect::loadMultiString(" << var.name << "Field);\n"
          else
            readDef << indent << var.name << " = " << var.name << "Field;\n"
          end
        end
      elsif var.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
        readDef << indent << XCTECpp::Utils::get_comment(var)
      elsif var.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
        readDef << var.formatText
      end
    end

    readDef << "}\n\n"

    bld.add readDef
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodProcessRow.new)
