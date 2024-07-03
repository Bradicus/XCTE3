##
# Class:: EFConfiguration
# Author:: Brad Ottoson
#

require "plugins_core/lang_csharp/utils"
require "plugins_core/lang_csharp/class_base"
require "plugins_core/lang_csharp/source_renderer_csharp"

require "code_structure/code_elem_parent"
require "lang_file"
require "x_c_t_e_plugin"

module XCTECSharp
  class ClassEFConfiguration < ClassBase
    def initialize
      @name = "ef_configuration"
      @language = "csharp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      return cls.get_u_name + " configuration"
    end

    def process_dependencies(cls)
      cls.addUse("Microsoft.EntityFrameworkCore")
      cls.addUse("Microsoft.EntityFrameworkCore.Metadata.Builders")
      Utils.instance.add_class_include(cls, "class_standard")
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      classDec = cls.model.visibility + " class " + get_class_name(cls) + " : IEntityTypeConfiguration<" + Utils.instance.style_as_class(cls.get_u_name) + ">"

      for par in (0..cls.base_classes.size)
        if par == 0 && !cls.base_classes[par].nil?
          classDec << " < " << cls.base_classes[par].visibility << " " << cls.base_classes[par].name
        elsif !cls.base_classes[par].nil?
          classDec << ", " << cls.base_classes[par].visibility << " " << cls.base_classes[par].name
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
