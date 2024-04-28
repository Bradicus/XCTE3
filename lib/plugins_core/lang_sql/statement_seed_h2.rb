##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin generates a create statement for a database based
# on this class

require "x_c_t_e_plugin"
require "plugins_core/lang_tsql/class_base"

module XCTETSql
  class StatementSeedH2 < ClassBase
    def initialize
      @name = "statement_seed_h2"
      @language = "sql"
      @category = XCTEPlugin::CAT_METHOD
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTSql.new
      bld.lfName = Utils.instance.style_as_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.get_extension("body")

      render_file_comment(cls, bld)
      render_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      sqlCDef = []
      first = true

      bld.add("INSERT INTO " + Utils.instance.style_as_class(cls.get_u_name))

      cols = []
      # Generate code for class variables
      each_var(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.hasManyToManyRelation
          cols.push(Utils.instance.get_styled_variable_name(var))
        end
      }))

      bld.add("  (" + cols.join(", ") + ")")

      bld.start_block(" VALUES ")
      count = 3

      for i in 1..count
        values = []

        each_var(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
          if Types.instance.inCategory(var, "text")
            values.push("'" + var.name + " " + i.to_s + "'")
          elsif Types.instance.inCategory(var, "time")
            values.push("'2024-04-15 11:0" + i.to_s + "'")
          else
            values.push(i.to_s)
          end
        }))

        bld.add("(" + values.join(", ") + ")")
      end

      bld.end_block
    end
  end
end

XCTEPlugin.registerPlugin(XCTETSql::StatementSeedH2.new)
