require 'lang_profile.rb'
require 'code_name_styling.rb'

module XCTECSharp
  class MethodTsqlReadSetBy < XCTEPlugin

    def initialize
      @name = "method_tsql_retrieve_set_by"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
      @author = "Brad Ottoson"
    end

    # Returns definition string for this class's constructor
    def get_definition(dataModel, genClass, genFun, cfg, codeBuilder)
      codeBuilder.add('/// <summary>')
      codeBuilder.add('/// Reads set of results using the specified filter parameters')
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

      return "List<" + standardClassName + "> " +
                                 XCTECSharp::Utils.instance.getStyledFunctionName("retrieve set by " + paramNames.join(" ")) +
                                 "(SqlTransaction trans, " + paramDec.join(', ') + ")"
    end

    def get_body(dataModel, genClass, genFun, cfg, codeBuilder)
      conDef = String.new
      varArray = Array.new
      dataModel.getAllVarsFor(cfg, varArray)

      styledClassName = XCTECSharp::Utils.instance.getStyledClassName(dataModel.name)
      codeBuilder.add('List<' + styledClassName + '> resultList = new List<' + styledClassName + '>();')

      codeBuilder.add('string sql = @"SELECT ')

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

      codeBuilder.add('var o = new ' + XCTECSharp::Utils.instance.getStyledClassName(dataModel.name) + '();')

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

      codeBuilder.add
      codeBuilder.add('resultList.Add(o);')

      codeBuilder.endBlock
      codeBuilder.endBlock

      codeBuilder.endBlock
      codeBuilder.startBlock("catch(Exception e)")
      codeBuilder.add('throw new Exception("Error retrieving all items from ' + dataModel.name + '", e);')
      codeBuilder.endBlock(';')

      codeBuilder.add
      codeBuilder.add('return resultList;')
    end

  end

end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlReadSetBy.new)
