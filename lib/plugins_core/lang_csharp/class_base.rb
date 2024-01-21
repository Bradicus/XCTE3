require "plugins_core/lang_csharp/utils.rb"
require "plugins_core/lang_csharp/source_renderer_csharp.rb"
require "x_c_t_e_class_base.rb"

# This class contains functions that may be usefull in any type of class
module XCTECSharp
  class ClassBase < XCTEClassBase
    def get_default_utils
      return Utils.instance
    end

    def get_source_renderer
      return SourceRendererCSharp.new
    end

    def gen_file_comment(cls, bld)
    end

    def get_sql_util(cls)
      if cls.model.findClassSpecByPluginName('tsql_data_store') != nil
        return XCTETSql::Utils.instance
      else
        return XCTESql::Utils.instance
      end
    end

    def render_namespace_start(cls, bld)
      return unless cls.namespace.hasItems?
      bld.start_block('namespace ' << cls.namespace.get('.'))
    end

    def render_namespace_end(cls, bld)
      return unless cls.namespace.hasItems?

      bld.end_block(' // namespace ' + cls.namespace.get('.'))
      bld.add
    end

    def render_dependencies(cls, bld)
      for use in cls.uses
        bld.add('using ' + use.namespace.get('.') + ';')
      end

      bld.separate
    end

  end
end
