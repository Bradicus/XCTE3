##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin generates a create statement for a database based
# on this class

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_tsql/class_base"

module XCTETSql
  class StatementCreate < ClassBase
    def initialize
      @name = "statement_create"
      @language = "tsql"
      @category = XCTEPlugin::CAT_METHOD
    end

    def getUnformattedClassName(cls)
      return cls.getUName()
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererTSql.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))
      bld.lfExtension = Utils.instance.getExtension("body")

      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the comment for this class
    def genFileComment(cls, bld)
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      sqlCDef = Array.new
      first = true

      bld.add("CREATE TABLE [" + cls.name + "] (")
      bld.indent

      # Generate code for class variables
      eachVar(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.hasManyToManyRelation()
          if !first
            bld.sameLine(", ")
          end
          first = false

          varDec = XCTETSql::Utils.instance.getVarDec(var, cls.varPrefix)
          if varDec != nil && varDec.strip().length > 0
            bld.add(varDec)
          end

          if var.defaultValue != nil
            bld.sameLine(" default '" << var.defaultValue << "'")
          end
        end
      }))

      primKeys = Array.new

      eachVar(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.isPrimary == true
          primKeys << "[" + Utils.instance.getStyledVariableName(var, cls.varPrefix) + "]"
        end
      }))

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
