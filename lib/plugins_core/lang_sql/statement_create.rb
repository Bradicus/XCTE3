##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin generates a create statement for a database based
# on this class

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_sql/x_c_t_e_sql.rb"

module XCTESql
  class StatementCreate < XCTEPlugin
    def initialize
      @name = "statement_create"
      @language = "sql"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_lines(cls, cfg)
      sqlCDef = Array.new
      indent = ""

      codeLine = indent + "CREATE TABLE `" + cls.get_u_name + "List` ("
      sqlCDef << codeLine
      sqlCDef << indent << "`id` INT"

      varArray = Array.new
      cls.getAllVarsFor(varArray)

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        codeLine = ", "

        codeLine << XCTESql::Utils::get_var_dec(var)

        if var.defaultValue != nil
          codeLine << " default '" << var.defaultValue << "'"
        end

        sqlCDef << codeLine
      }))

      sqlCDef << indent << ", PRIMARY KEY (`id`)"

      sqlCDef << indent << " ) ENGINE=MyISAM DEFAULT CHARSET=utf8;"

      return(sqlCDef)
    end
  end
end
