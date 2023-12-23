##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin generates a create statement for a database based
# on this class

require 'x_c_t_e_plugin'
require 'plugins_core/lang_tsql/class_base'

module XCTETSql
  class StatementCreate < ClassBase
    def initialize
      @name = 'statement_create'
      @language = 'tsql'
      @category = XCTEPlugin::CAT_METHOD
    end

    def get_unformatted_class_name(cls)
      cls.getUName
    end

    def genSourceFiles(cls)
      srcFiles = []

      bld = SourceRendererTSql.new
      bld.lfName = Utils.instance.getStyledFileName(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.getExtension('body')

      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      srcFiles
    end

    # Returns the code for the comment for this class
    def genFileComment(cls, bld); end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      sqlCDef = []
      first = true

      bld.add('CREATE TABLE [' + cls.name + '] (')
      bld.indent

      # Generate code for class variables
      eachVar(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.hasManyToManyRelation
          bld.sameLine(', ') if !first
          first = false

          varDec = XCTETSql::Utils.instance.getVarDec(var, cls.varPrefix)
          bld.add(varDec) if !varDec.nil? && varDec.strip.length > 0

          bld.sameLine(" default '" << var.defaultValue << "'") if !var.defaultValue.nil?
        end
      }))

      primKeys = []

      eachVar(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        primKeys << '[' + Utils.instance.get_styled_variable_name(var, cls.varPrefix) + ']' if var.isPrimary == true
      }))

      if primKeys.length > 0
        bld.sameLine(',')
        bld.add('PRIMARY KEY (' + primKeys.join(', ') + ')')
      end

      bld.unindent
      bld.add(') ')
    end
  end
end

XCTEPlugin.registerPlugin(XCTETSql::StatementCreate.new)
