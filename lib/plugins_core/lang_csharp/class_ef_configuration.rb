##
# Class:: EFConfiguration
# Author:: Brad Ottoson
#

require 'plugins_core/lang_csharp/utils'
require 'plugins_core/lang_csharp/class_base'
require 'plugins_core/lang_csharp/source_renderer_csharp'

require 'code_elem_parent'
require 'lang_file'
require 'x_c_t_e_plugin'

module XCTECSharp
  class ClassEFConfiguration < ClassBase
    def initialize
      @name = 'ef_configuration'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_class_name(cls)
      return Utils.instance.get_styled_class_name(cls.getUName + ' configuration')
    end

    def process_dependencies(cls, _bld)
      cls.addUse('Microsoft.EntityFrameworkCore')
      cls.addUse('Microsoft.EntityFrameworkCore.Metadata.Builders')
      Utils.instance.add_class_include(cls, 'standard')
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      classDec = cls.model.visibility + ' class ' + get_class_name(cls) + ' : IEntityTypeConfiguration<' + Utils.instance.get_styled_class_name(cls.getUName) + '>'

      for par in (0..cls.baseClassModelManager.size)
        if par == 0 && !cls.baseClasses[par].nil?
          classDec << ' < ' << cls.baseClasses[par].visibility << ' ' << cls.baseClasses[par].name
        elsif !cls.baseClasses[par].nil?
          classDec << ', ' << cls.baseClasses[par].visibility << ' ' << cls.baseClasses[par].name
        end
      end

      bld.start_class(classDec)

      # Generate code for functions
      render_functions(cls, bld)

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTECSharp::ClassEFConfiguration.new)
