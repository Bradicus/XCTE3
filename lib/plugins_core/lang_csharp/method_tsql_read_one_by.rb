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
      codeBuilder.add("/**")
      codeBuilder.add("* Reads data set from sql database")
      codeBuilder.add("*/")

      genClass.name = CodeNameStyling.stylePascal(dataModel.name)

      params = Array.new
      dataModel.xmlElement.elements.each("var_ref") {|refXml|
        params << dataModel.vars.find { |var| var.name == refXml.attributes["name"] }
      }

      paramDec = Array.new

      params.each() {|param|
        paramDec << XCTECSharp::Utils.instance.getParamDec(param)
      }

      codeBuilder.startClass("public IEnumerable<" + genClass.name + "> RetrieveOneBy(SqlTransaction trans, " + paramDec.join(', ') + ")")

      get_body(dataModel, genClass, genFun, cfg, codeBuilder)

      codeBuilder.endClass
    end

    def get_declairation(dataModel, genClass, genFun, cfg, codeBuilder)

      genClass.name = CodeNameStyling.stylePascal(dataModel.name)

      varArray = Array.new
      dataModel.getAllVarsFor(cfg, varArray)
      params = Array.new
      genFun.xmlElement.elements.each("var_ref") {|refXml|
        params << dataModel.vars.find { |var| var.name == refXml.attributes["name"] }
      }

      paramDec = Array.new

      params.each() {|param|
        paramDec << XCTECSharp::Utils.instance.getParamDec(param)
      }

      styledClassName = XCTECSharp::Utils.instance.getStyledClassName(dataModel.name)
      codeBuilder.add("IEnumerable<" + styledClassName + "> RetrieveOneBy(SqlTransaction trans, " + paramDec.join(', ') + ");")
    end

    def get_dependencies(dataModel, genClass, genFun, cfg, codeBuilder)
      genClass.addInclude('System.Collections.Generic', 'IEnumerable')
      genClass.addInclude('System.Data.SqlClient', 'SqlTransaction')
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

          codeBuilder.add(CodeNameStyling.stylePascal(var.name))
        else
          if var.elementId == CodeElem::ELEM_FORMAT
            codeBuilder.add(var.formatText)
          end
        end
      end

      codeBuilder.unindent

      codeBuilder.add('FROM ' + dataModel.name + '";')


      codeBuilder.add

      codeBuilder.startBlock("try")
      codeBuilder.startBlock("using(SqlCommand cmd = new SqlCommand(sql, trans.Connection))")

      codeBuilder.add

      codeBuilder.add('SqlDataReader results = cmd.ExecuteReader();')

      codeBuilder.startBlock('while(results.Read())')

      codeBuilder.add('var o = new ' + XCTECSharp::Utils.instance.getStyledClassName(dataModel.name) + '();')

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE && var.listType == nil && XCTECSharp::Utils.instance.isPrimitive(var)
          resultVal = 'results["' + XCTECSharp::Utils.instance.getStyledVariableName(var) + '"]'
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
      codeBuilder.add('throw new Exception("Error retrieving all items from ' + dataModel.name + '", e);')
      codeBuilder.endBlock(';')

      codeBuilder.add
      codeBuilder.add('return resultList;')
    end

  end

end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodTsqlReadOneBy.new)
