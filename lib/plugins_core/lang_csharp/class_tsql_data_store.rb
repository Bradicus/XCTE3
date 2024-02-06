##
# Class:: Standard
# Author:: Brad Ottoson
#

require 'plugins_core/lang_csharp/utils'
require 'plugins_core/lang_csharp/class_base'
require 'plugins_core/lang_csharp/source_renderer_csharp'

require 'code_elem_parent'
require 'lang_file'
require 'x_c_t_e_plugin'

module XCTECSharp
  class ClassTsqlDataStore < ClassBase
    def initialize
      @name = 'tsql_data_store'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name + ' data store'
    end

    def gen_source_files(cls)
      srcFiles = []

      if cls.interface_namespace.hasItems?
        cls.addUse(cls.interface_namespace.get('.'), 'I' + get_unformatted_class_name(cls))
        Utils.instance.add_class_include(cls, 'standard')
      end

      bld = SourceRendererCSharp.new
      bld.lfName = Utils.instance.get_styled_file_name(cls.get_u_name)
      bld.lfExtension = Utils.instance.get_extension('body')
      render_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)

      classDec = cls.model.visibility + ' class ' + get_class_name(cls)

      inheritsFrom = []

      for baseClass in cls.base_classes
        inheritsFrom << baseClass.name
      end
      if cls.interface_namespace.hasItems?
        inheritsFrom << Utils.instance.get_styled_class_name('i ' + get_unformatted_class_name(cls))
      end

      for par in (0..inheritsFrom.size)
        if par == 0 && !inheritsFrom[par].nil?
          classDec << ' : ' << inheritsFrom[par]
        elsif !inheritsFrom[par].nil?
          classDec << ', ' << inheritsFrom[par]
        end
      end

      bld.start_class(classDec)

      render_functions(cls, bld)

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTECSharp::ClassTsqlDataStore.new)
