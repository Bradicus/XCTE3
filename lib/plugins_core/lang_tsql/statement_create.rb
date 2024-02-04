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
      cls.get_u_name
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTSql.new
      bld.lfName = Utils.instance.get_styled_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.get_extension('body')

      render_file_comment(cls, bld)
      render_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      sqlCDef = []
      first = true

      bld.add('CREATE TABLE [' + cls.name + '] (')
      bld.indent

      # Generate code for class variables
      each_var(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.hasManyToManyRelation
          bld.same_line(', ') if !first
          first = false

          varDec = XCTETSql::Utils.instance.get_var_dec(var, cls.var_prefix)
          bld.add(varDec) if !varDec.nil? && varDec.strip.length > 0

          bld.same_line(" default '" << var.defaultValue << "'") if !var.defaultValue.nil?
        end
      }))

      primKeys = []

      each_var(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        primKeys << '[' + Utils.instance.get_styled_variable_name(var, cls.var_prefix) + ']' if var.isPrimary == true
      }))

      if primKeys.length > 0
        bld.same_line(',')
        bld.add('PRIMARY KEY (' + primKeys.join(', ') + ')')
      end

      bld.unindent
      bld.add(') ')
    end
  end
end

XCTEPlugin.registerPlugin(XCTETSql::StatementCreate.new)
