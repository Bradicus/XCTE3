##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an equality assignment operator for making
# a copy of a class

require "plugins_core/lang_cpp/x_c_t_e_cpp"

class XCTECpp::MethodDefine < XCTEPlugin
  def initialize
    @name = "method_define"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's define function
  def render_declaration(fp_params)
    bld = fp_params.bld
    cls = fp_params.cls_spec

    varArray = []
    cls.getAllVarsFor(varArray)

    eqString = String.new
    seperator = ""
    bld.add("void define(")

    for var in varArray
      if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && !var.isStatic && XCTECpp::Utils.is_primitive(var) && (var.arrayElemCount.to_i == 0) # Ignore arrays
        bld.same_line(seperator + XCTECpp::Utils.get_type_name(var.vtype) + " ")
        bld.same_line("new" << XCTECpp::Utils.get_capitalized_first(var.name))
        bld.same_line(seperator = ", ")
      end
    end

    bld.same_line(");")

    return eqString
  end

  # Returns declairation string for this class's define function
  def render_declaration_inline(fp_params)
    bld = fp_params.bld
    cls = fp_params.cls_spec

    eqString = String.new
    seperator = ""
    bld.add("void define(")

    Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
      if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && !var.isStatic && XCTECpp::Utils.is_primitive(var) && (var.arrayElemCount.to_i == 0) # Ignore arrays
        bld.same_line(seperator << XCTECpp::Utils.get_type_name(var.vtype) << " ")
        bld.same_line("new" << XCTECpp::Utils.get_capitalized_first(var.name))
        seperator = ", "
      end
    }))

    bld.same_line(")")
    bld.start_block
    get_body(cls, bld)
  end

  # Returns definition string for this class's equality assignment operator
  def render_function(cls, bld)
    seperator = ""
    longArrayFound = false
    varArray = []
    cls.getAllVarsFor(varArray)

    bld.add("/**\n* Defines the variables in an object\n*/")
    bld.add("void " << cls.name << " :: define(")

    for var in varArray
      if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && !var.isStatic && XCTECpp::Utils.is_primitive(var) && (var.arrayElemCount.to_i == 0) # Ignore arrays
        bld.same_line(seperator << XCTECpp::Utils.get_type_name(var.vtype) << " ")
        bld.same_line("new" << XCTECpp::Utils.get_capitalized_first(var.name))
        seperator = ", "
      end
    end

    bld.same_line(")")
    bld.start_block

    #    if cls.has_an_array
    #      eqString << "    unsigned int i;\n\n";
    #    end

    eqString << get_body(cls, "    ")

    bld.end_block
    bld.add
  end

  ## Get body of function
  def get_body(fp_params)
    bld = fp_params.bld
    cls = fp_params.cls_spec

    eqString = String.new
    seperator = ""
    longArrayFound = false
    varArray = []
    cls.getAllVarsFor(varArray)

    varArray = []
    cls.getAllVarsFor(varArray)

    for var in varArray
      if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && !var.isStatic && Utils.instance.is_primitive(var)
        eqString << indent << var.name << " = "
        eqString << "new" << Utils.instance.get_styled_variable_name(var) << ";\n"
      end
    end

    return(eqString)
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodDefine.new)
