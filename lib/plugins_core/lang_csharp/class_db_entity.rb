##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for jpa entity classes,

require 'plugins_core/lang_csharp/utils'
require 'plugins_core/lang_csharp/class_base'
require 'code_elem'
require 'code_elem_parent'
require 'code_elem_model'
require 'lang_file'

module XCTECSharp
  class ClassDbEntity < ClassBase
    def initialize
      super

      @name = 'class_db_entity'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName
    end

    def process_dependencies(cls, bld)
      cls.addUse('Microsoft.EntityFrameworkCore')
      cls.addUse('Microsoft.EntityFrameworkCore.Metadata.Builders')
      super
    end

    # Returns the code for the header for this class
    def gen_body_content(cls, bld)
      bld.separate
      clsName = get_class_name(cls)
      tableName = get_sql_util(cls).getStyledClassName(cls.getUName)

      bld.start_class('public class ' + clsName)

      each_var(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.arrayElemCount > 0
          bld.add('public const int ' + Utils.instance.get_size_const(var) + ' = ' << var.arrayElemCount.to_s + ';')
        end
      }))

      bld.separate if Utils.instance.has_an_array?(cls)

      # Generate class variables
      each_var(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.name == 'id'
          bld.add(Utils.instance.getVarDec(var))
        else
          bld.add(Utils.instance.getVarDec(var))
        end
      }))

      bld.separate

      render_functions(cls, bld)

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTECSharp::ClassDbEntity.new)
