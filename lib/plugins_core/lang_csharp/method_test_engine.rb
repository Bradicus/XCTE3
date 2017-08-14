
class MethodTestEngine
end
##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_csharp/x_c_t_e_csharp.rb'

class XCTECSharp::MethodTestEngine < XCTEPlugin

  def initialize
    @name = "method_test_engine"
    @language = "csharp"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns definition string for this class's constructor
  def get_definition(dataModel, genClass, cfg, codeBuilder)
    codeBuilder.add("///")
    codeBuilder.add("/// Constructor")
    codeBuilder.add("///")

    codeBuilder.startFunction('public void ' + Utils.instance.getStyledFunctionName("test engine") + '()')
    get_body(dataModel, genClass, cfg, codeBuilder)

    codeBuilder.endFunction
  end

  def get_dependencies(dataModel, genClass, cfg, codeBuilder)
    genClass.addInclude('System.Collections.Generic', 'IEnumerable')
    genClass.addInclude('System.Data.SqlClient', 'SqlTransaction')
    genClass.addInclude('XCTE.Foundation', Utils.instance.getStyledClassName('i ' + dataModel.name + ' engine'))
    genClass.addInclude('XCTE.Data', Utils.instance.getStyledClassName(dataModel.name + ' engine'))
  end

  def get_body(dataModel, genClass, cfg, codeBuilder)

    codeBuilder.add('I' + dataModel.name + 'Engine intf;')
    codeBuilder.add(dataModel.name + ' obj = new ' + dataModel.name + '();')
    codeBuilder.add('intf = new ' + dataModel.name + 'Engine();')
    codeBuilder.add('SqlConnection conn = new SqlConnection("Data Source=localhost;Initial Catalog=Test; Integrated Security=SSPI;");')

    codeBuilder.add

    varArray = Array.new
    dataModel.getAllVarsFor(cfg, varArray)

    # Generate class variables
    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if var.vtype == 'String'
          codeBuilder.add('obj.'+ Utils.instance.getStyledVariableName(var) + ' = "Test String";')
        elsif var.vtype.start_with?('Int')
          codeBuilder.add('obj.'+ Utils.instance.getStyledVariableName(var) + ' = 43;')
        elsif var.vtype.start_with?('Decimal')
          codeBuilder.add('obj.'+ Utils.instance.getStyledVariableName(var) + ' = 43.2;')
        elsif var.vtype.start_with?('Float')
          codeBuilder.add('obj.'+ Utils.instance.getStyledVariableName(var) + ' = 43.2;')
        end
      end
    end

    # Generate code for functions
    for fun in genClass.functions
      if fun.elementId == CodeElem::ELEM_FUNCTION
        if fun.isTemplate
          templ = XCTEPlugin::findMethodPlugin("csharp", fun.name)
          if templ != nil
            templ.get_definition(dataModel, genClass, fun, cfg, codeBuilder)
          else
            puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
          end

          codeBuilder.add
        end
      end
    end  # class  + dataModel.name
  end

end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTestEngine.new)

