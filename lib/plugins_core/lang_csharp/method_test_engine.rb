class MethodTestEngine
end

##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin.rb"

module XCTECSharp
  class MethodTestEngine < XCTEPlugin
    def initialize
      @name = "method_test_engine"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, cfg, codeBuilder)
      codeBuilder.add("///")
      codeBuilder.add("/// Constructor")
      codeBuilder.add("///")

      codeBuilder.add("[TestMethod]")
      codeBuilder.startFunction("public void " + Utils.instance.getStyledFunctionName("test " + cls.getUName() + " engine") + "()")
      get_body(cls, cfg, codeBuilder)

      codeBuilder.endFunction
    end

    def process_dependencies(cls, cfg, codeBuilder)
      cls.addUse("System.Collections.Generic", "IEnumerable")
      cls.addUse("System.Data.SqlClient", "SqlConnection")
      cls.addUse("System.Configuration", "ConfigurationManager")
      cls.addUse("System", "Exception")
      cls.addUse("System.Transactions", "TransactionScope")
      cls.addUse("Microsoft.VisualStudio.TestTools.UnitTesting", "TestMethod")
      cls.addUse("XCTE.Foundation", Utils.instance.getStyledClassName("i " + cls.getUName() + " engine"))
      cls.addUse("XCTE.Data", Utils.instance.getStyledClassName(cls.getUName() + " engine"))
    end

    def get_body(cls, cfg, codeBuilder)
      stdClassName = Utils.instance.getStyledClassName(cls.getUName())

      codeBuilder.add(Utils.instance.getStyledClassName("i " + cls.getUName() + " engine") + " intf = new " + Utils.instance.getStyledClassName(cls.getUName() + " engine") + "();")
      codeBuilder.add(stdClassName + " obj = new " + stdClassName + "();")
      codeBuilder.add
      codeBuilder.add('string connString = ConfigurationManager.ConnectionStrings["testDb"].ConnectionString;')

      codeBuilder.add

      codeBuilder.startBlock("try")
      codeBuilder.startBlock("using (var tScope = new TransactionScope())")
      codeBuilder.startBlock("using (SqlConnection conn = new SqlConnection(connString))")
      codeBuilder.add("conn.Open();")

      varArray = Array.new
      cls.model.getNonIdentityVars(varArray)

      # # Generate class variables
      # for var in varArray
      #   if var.elementId == CodeElem::ELEM_VARIABLE
      #       if var.vtype == 'String'
      #         codeBuilder.add('obj.'+ Utils.instance.getStyledVariableName(var) + ' = "TS";')
      #       elsif var.vtype.start_with?('Int')
      #         codeBuilder.add('obj.'+ Utils.instance.getStyledVariableName(var) + ' = 43;')
      #       elsif var.vtype.start_with?('Decimal')
      #         codeBuilder.add('obj.'+ Utils.instance.getStyledVariableName(var) + ' = 43.2;')
      #       elsif var.vtype.start_with?('Float')
      #         codeBuilder.add('obj.'+ Utils.instance.getStyledVariableName(var) + ' = 43.2;')
      #       end
      #     end
      # end

      codeBuilder.add
      codeBuilder.add("intf.Create(obj, conn);")

      codeBuilder.endBlock

      codeBuilder.add
      codeBuilder.add("tScope.Complete();")

      codeBuilder.endBlock
      codeBuilder.endBlock

      codeBuilder.startBlock("catch(Exception e)")
      codeBuilder.add('throw new Exception("Failed to create new test object for ' + stdClassName + '", e);')
      codeBuilder.endBlock

      # Generate code for functions
      for fun in cls.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin::findMethodPlugin("csharp", fun.name)
            if templ != nil
              templ.get_definition(cls, fun, cfg, codeBuilder)
            else
              puts "ERROR no plugin for function: " + fun.name + "   language: csharp"
            end

            codeBuilder.add
          end
        end
      end  # class  + cls.getUName()
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTestEngine.new)
