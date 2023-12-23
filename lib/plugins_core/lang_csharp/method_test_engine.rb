class MethodTestEngine
end

##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'x_c_t_e_plugin'

module XCTECSharp
  class MethodTestEngine < XCTEPlugin
    def initialize
      @name = 'method_test_engine'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, bld)
      bld.add('///')
      bld.add('/// Constructor')
      bld.add('///')

      bld.add('[TestMethod]')
      bld.startFunction('public void ' + Utils.instance.getStyledFunctionName('test ' + cls.getUName + ' engine') + '()')
      get_body(cls, bld)

      bld.endFunction
    end

    def process_dependencies(cls, _bld)
      cls.addUse('System.Collections.Generic', 'IEnumerable')
      cls.addUse('System.Data.SqlClient', 'SqlConnection')
      cls.addUse('System.Configuration', 'ConfigurationManager')
      cls.addUse('System', 'Exception')
      cls.addUse('System.Transactions', 'TransactionScope')
      cls.addUse('Microsoft.VisualStudio.TestTools.UnitTesting', 'TestMethod')
      cls.addUse('XCTE.Foundation', Utils.instance.get_styled_class_name('i ' + cls.getUName + ' engine'))
      cls.addUse('XCTE.Data', Utils.instance.get_styled_class_name(cls.getUName + ' engine'))
    end

    def get_body(cls, bld)
      stdClassName = Utils.instance.get_styled_class_name(cls.getUName)

      bld.add(Utils.instance.get_styled_class_name('i ' + cls.getUName + ' engine') + ' intf = new ' + Utils.instance.get_styled_class_name(cls.getUName + ' engine') + '();')
      bld.add(stdClassName + ' obj = new ' + stdClassName + '();')
      bld.add
      bld.add('string connString = ConfigurationManager.ConnectionStrings["testDb"].ConnectionString;')

      bld.add

      bld.startBlock('try')
      bld.startBlock('using (var tScope = new TransactionScope())')
      bld.startBlock('using (SqlConnection conn = new SqlConnection(connString))')
      bld.add('conn.Open();')

      varArray = []
      cls.model.getNonIdentityVars(varArray)

      # # Generate class variables
      # for var in varArray
      #   if var.elementId == CodeElem::ELEM_VARIABLE
      #       if var.vtype == 'String'
      #         bld.add('obj.'+ Utils.instance.get_styled_variable_name(var) + ' = "TS";')
      #       elsif var.vtype.start_with?('Int')
      #         bld.add('obj.'+ Utils.instance.get_styled_variable_name(var) + ' = 43;')
      #       elsif var.vtype.start_with?('Decimal')
      #         bld.add('obj.'+ Utils.instance.get_styled_variable_name(var) + ' = 43.2;')
      #       elsif var.vtype.start_with?('Float')
      #         bld.add('obj.'+ Utils.instance.get_styled_variable_name(var) + ' = 43.2;')
      #       end
      #     end
      # end

      bld.add
      bld.add('intf.Create(obj, conn);')

      bld.endBlock

      bld.add
      bld.add('tScope.Complete();')

      bld.endBlock
      bld.endBlock

      bld.startBlock('catch(Exception e)')
      bld.add('throw new Exception("Failed to create new test object for ' + stdClassName + '", e);')
      bld.endBlock

      # Generate code for functions
      for fun in cls.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION && fun.isTemplate
          templ = XCTEPlugin.findMethodPlugin('csharp', fun.name)
          if !templ.nil?
            templ.get_definition(cls, bld, fun)
          else
            puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
          end

          bld.add
        end
      end # class  + cls.getUName()
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECSharp::MethodTestEngine.new)
