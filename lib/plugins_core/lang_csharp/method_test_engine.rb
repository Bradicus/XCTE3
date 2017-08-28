
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

module XCTECSharp
  class MethodTestEngine < XCTEPlugin

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

      codeBuilder.add('[TestMethod]')
      codeBuilder.startFunction('public void ' + Utils.instance.getStyledFunctionName("test " + dataModel.name + " engine()"))
      get_body(dataModel, genClass, cfg, codeBuilder)

      codeBuilder.endFunction
    end

    def get_dependencies(dataModel, genClass, cfg, codeBuilder)
      genClass.addUse('System.Collections.Generic', 'IEnumerable')
      genClass.addUse('System.Data.SqlClient', 'SqlTransaction')
      genClass.addUse('System.Configuration', 'ConfigurationManager')
      genClass.addUse('System', 'Exception')
      genClass.addUse('Microsoft.VisualStudio.TestTools.UnitTesting', 'TestMethod');
      genClass.addUse('XCTE.Foundation', Utils.instance.getStyledClassName('i ' + dataModel.name + ' engine'))
      genClass.addUse('XCTE.Data', Utils.instance.getStyledClassName(dataModel.name + ' engine'))
    end

    def get_body(dataModel, genClass, cfg, codeBuilder)

      codeBuilder.add('I' + dataModel.name + 'Engine intf = new ' + dataModel.name + 'Engine();')
      codeBuilder.add(dataModel.name + ' obj = new ' + dataModel.name + '();')
      codeBuilder.add
      codeBuilder.add('string connString = ConfigurationManager.ConnectionStrings["testDb"].ConnectionString;')
      codeBuilder.add('SqlConnection conn = new SqlConnection(connString);')
      codeBuilder.add('conn.Open();')
      codeBuilder.add('SqlTransaction trans = conn.BeginTransaction();')

      codeBuilder.add

      codeBuilder.startBlock('try')

      varArray = Array.new
      dataModel.getNonIdentityVars(varArray)

      # Generate class variables
      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
            if var.vtype == 'String'
              codeBuilder.add('obj.'+ Utils.instance.getStyledVariableName(var) + ' = "TS";')
            elsif var.vtype.start_with?('Int')
              codeBuilder.add('obj.'+ Utils.instance.getStyledVariableName(var) + ' = 43;')
            elsif var.vtype.start_with?('Decimal')
              codeBuilder.add('obj.'+ Utils.instance.getStyledVariableName(var) + ' = 43.2;')
            elsif var.vtype.start_with?('Float')
              codeBuilder.add('obj.'+ Utils.instance.getStyledVariableName(var) + ' = 43.2;')
            end
          end
      end

      codeBuilder.add
      codeBuilder.add('intf.Create(trans, obj);')

      codeBuilder.endBlock
      codeBuilder.startBlock('catch(Exception e)')
      codeBuilder.startBlock('try')
      codeBuilder.add('trans.Rollback();')
      codeBuilder.endBlock
      codeBuilder.startBlock('catch(Exception er)')
      codeBuilder.add('throw new Exception("Failed to rollback transaction after exception", er);')
      codeBuilder.endBlock
      codeBuilder.add('throw new Exception("Failed to create new test object for ' + Utils.instance.getStandardName(dataModel) + '", e);')
      codeBuilder.endBlock

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
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTestEngine.new)

