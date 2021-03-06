##

# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin generates a create statement for a database based 
# on this class
 
require 'x_c_t_e_plugin.rb'

module XCTETSql
  class StatementCreate < XCTEPlugin
      
    def initialize
      @name = "statement_create"
      @language = "tsql"
      @category = XCTEPlugin::CAT_METHOD
      @author = "Brad Ottoson"
    end

    def getClassName(dataModel, genClass)
      return XCTETSql::Utils.instance.getStyledClassName(dataModel.name)
    end

    def genSourceFiles(dataModel, genClass, cfg)
      srcFiles = Array.new

      genClass.setName(getClassName(dataModel, genClass))

      codeBuilder = SourceRenderer.new
      codeBuilder.lfName = dataModel.name
      codeBuilder.lfExtension = 'sql'
      genFileContent(dataModel, genClass, cfg, codeBuilder)

      srcFiles << codeBuilder

      return srcFiles
    end

    # Returns definition string for this class's constructor
    def genFileContent(dataModel, genClass, cfg, codeBuilder)
      sqlCDef = Array.new
      first = true

      codeBuilder.add("CREATE TABLE [" + genClass.name + "] (")
      codeBuilder.indent

      varArray = Array.new
      dataModel.getAllVarsFor(varArray)

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          if !first
            codeBuilder.sameLine(", ")
          end
          first = false

          codeBuilder.add(XCTETSql::Utils.instance.getVarDec(var, genClass.varPrefix))

          if var.defaultValue != nil
            codeBuilder.sameLine(" default '" << var.defaultValue << "'")
          end
        end
      end

      primKeys = Array.new
      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          if var.isPrimary == true
            primKeys << '[' + Utils.instance.getStyledVariableName(var, genClass.varPrefix) + ']'
          end
        end
      end

      if primKeys.length > 0
        codeBuilder.sameLine(',')
        codeBuilder.add("PRIMARY KEY (" + primKeys.join(', ') + ")")
      end

      codeBuilder.unindent
      codeBuilder.add(") ")

    end
  end
end

XCTEPlugin::registerPlugin(XCTETSql::StatementCreate.new)
