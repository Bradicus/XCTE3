##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin generates a create statement for a database based
# on this class

require "x_c_t_e_plugin.rb"

module XCTETSql
  class StatementCreate < XCTEPlugin
    def initialize
      @name = "statement_create"
      @language = "tsql"
      @category = XCTEPlugin::CAT_METHOD
      @author = "Brad Ottoson"
    end

    def getClassName(cls)
      return XCTETSql::Utils.instance.getStyledClassName(cls.getUName())
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      cls.setName(getClassName(cls))

      codeBuilder = SourceRenderer.new
      codeBuilder.lfName = cls.getUName()
      codeBuilder.lfExtension = "sql"
      genFileContent(cls, cfg, codeBuilder)

      srcFiles << codeBuilder

      return srcFiles
    end

    # Returns definition string for this class's constructor
    def genFileContent(cls, cfg, codeBuilder)
      sqlCDef = Array.new
      first = true

      codeBuilder.add("CREATE TABLE [" + cls.name + "] (")
      codeBuilder.indent

      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          if !first
            codeBuilder.sameLine(", ")
          end
          first = false

          codeBuilder.add(XCTETSql::Utils.instance.getVarDec(var, cls.varPrefix))

          if var.defaultValue != nil
            codeBuilder.sameLine(" default '" << var.defaultValue << "'")
          end
        end
      end

      primKeys = Array.new
      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          if var.isPrimary == true
            primKeys << "[" + Utils.instance.getStyledVariableName(var, cls.varPrefix) + "]"
          end
        end
      end

      if primKeys.length > 0
        codeBuilder.sameLine(",")
        codeBuilder.add("PRIMARY KEY (" + primKeys.join(", ") + ")")
      end

      codeBuilder.unindent
      codeBuilder.add(") ")
    end
  end
end

XCTEPlugin::registerPlugin(XCTETSql::StatementCreate.new)
