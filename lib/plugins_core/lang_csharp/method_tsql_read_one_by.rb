require 'lang_profile.rb'
require 'code_name_styling.rb'

module XCTECSharp
  class MethodTsqlReadOneBy < XCTEPlugin

    def initialize
      @name = "method_tsql_retrieve_one_by"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
      @author = "Brad Ottoson"
    end

    # Returns definition string for this class's constructor
    def get_definition(dataModel, genClass, genFun, cfg, codeBuilder)
      codeBuilder.add('/// <summary>')
      codeBuilder.add('/// Reads one result using the specified filter parameters')
      codeBuilder.add('/// </summary>')
      codeBuilder.startFunction("public " + get_function_signature(dataModel, genClass, genFun, cfg, codeBuilder))

      get_body(dataModel, genClass, genFun, cfg, codeBuilder)

      codeBuilder.endFunction
    end

    def get_declairation(dataModel, genClass, genFun, cfg, codeBuilder)

      codeBuilder.add(get_function_signature(dataModel, genClass, genFun, cfg, codeBuilder) + ";")
    end

    def get_dependencies(dataModel, genClass, genFun, cfg, codeBuilder)
      genClass.addInclude('System.Collections.Generic', 'IEnumerable')
      genClass.addInclude('System.Data.SqlClient', 'SqlTransaction')
    end

    def get_function_signature(dataModel, genClass, genFun, cfg, codeBuilder)
      standardClassName = XCTECSharp::Utils.instance.getStyledClassName(dataModel.name)

      paramDec = Array.new
      paramNames = Array.new

      genFun.variableReferences.each() {|param|
        paramDec << XCTECSharp::Utils.instance.getParamDec(param.getParam())
        paramNames << XCTECSharp::Utils.instance.getStyledVariableName(param)
      }

      return standardClassName + ' ' + XCTECSharp::Utils.instance.getStyledFunctionName("retrieve one by " + paramNames.join(" ")) +
                                 "(SqlTransaction trans, " + paramDec.join(', ') + ")"
    end

    def get_body(dataModel, genClass, genFun, cfg, codeBuilder)
      conDef = String.new
      varArray = Array.new
      dataModel.getAllVarsFor(cfg, varArray)

      styledClassName = XCTECSharp::Utils.instance.getStyledClassName(dataModel.name)

      codeBuilder.add('var o = new ' + XCTECSharp::Utils.instance.getStyledClassName(dataModel.name) + '();')

      codeBuilder.add('string sql = @"SELECT TOP 1 ')

      codeBuilder.indent

      first = true;
      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          if !first
            codeBuilder.sameLine(',')
          end
          first = false

          codeBuilder.add(XCTETSql::Utils.instance.getStyledVariableName(var))
        else
          if var.elementId == CodeElem::ELEM_FORMAT
            codeBuilder.add(var.formatText)
          end
        end
      end

      codeBuilder.unindent

      codeBuilder.add('FROM ' + dataModel.name)
      codeBuilder.add('WHERE ')

      codeBuilder.indent

      whereItems = Array.new
      genFun.variableReferences.each() {|param|
        whereCondition =
              XCTETSql::Utils.instance.getStyledVariableName(param.getParam()) +
                " = @" +  XCTETSql::Utils.instance.getStyledVariableName(param.getParam())

        whereItems << whereCondition
      }
      codeBuilder.add(whereItems.join(" AND "))
      codeBuilder.sameLine('";')

      codeBuilder.unindent

      codeBuilder.add

      codeBuilder.startBlock("try")
      codeBuilder.startBlock("using(SqlCommand cmd = new SqlCommand(sql, trans.Connection))")

      genFun.variableReferences.each() {|param|
        codeBuilder.add("cmd.Parameters.AddWithValue(" +
                            '"@' + XCTETSql::Utils.instance.getStyledVariableName(param) +
                            '", ' +  XCTECSharp::Utils.instance.getStyledVariableName(param.getParam()) + ');'
                            )
      }

      codeBuilder.add('SqlDataReader results = cmd.ExecuteReader();')

      codeBuilder.startBlock('while(results.Read())')

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE && var.listType == nil && XCTECSharp::Utils.instance.isPrimitive(var)
          resultVal = 'results["' + XCTETSql::Utils.instance.getStyledVariableName(var) + '"]'
          objVar = "o." + XCTECSharp::Utils.instance.getStyledVariableName(var)

          if var.nullable
            codeBuilder.add(objVar + ' = ' + resultVal + ' == DBNull.Value ? null : Convert.To' +
                                var.vtype + "(" + resultVal + ");")
          else
            codeBuilder.add(objVar + ' = Convert.To' +
                                var.vtype + "(" + resultVal + ");")
          end
        end
      end

      codeBuilder.endBlock
      codeBuilder.endBlock

      codeBuilder.endBlock
      codeBuilder.startBlock("catch(Exception e)")
      codeBuilder.add('throw new Exception("Error retrieving one item from ' + dataModel.name + '", e);')
      codeBuilder.endBlock(';')

      codeBuilder.add
      codeBuilder.add('return o;')
    end

  end

end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlReadOneBy.new)
