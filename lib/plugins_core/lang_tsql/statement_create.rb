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

      bld = SourceRenderer.new
      bld.lfName = cls.getUName()
      bld.lfExtension = "sql"
      genFileContent(cls, cfg, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns definition string for this class's constructor
    def genFileContent(cls, cfg, bld)
      sqlCDef = Array.new
      first = true

      bld.add("CREATE TABLE [" + cls.name + "] (")
      bld.indent

      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          if !first
            bld.sameLine(", ")
          end
          first = false

          bld.add(XCTETSql::Utils.instance.getVarDec(var, cls.varPrefix))

          if var.defaultValue != nil
            bld.sameLine(" default '" << var.defaultValue << "'")
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
        bld.sameLine(",")
        bld.add("PRIMARY KEY (" + primKeys.join(", ") + ")")
      end

      bld.unindent
      bld.add(") ")
    end
  end
end

XCTEPlugin::registerPlugin(XCTETSql::StatementCreate.new)
