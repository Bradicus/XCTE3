##
# Class:: Standard
# Author:: Brad Ottoson
#

require 'plugins_core/lang_csharp/utils'
require 'plugins_core/lang_csharp/class_base'
require 'plugins_core/lang_csharp/source_renderer_csharp'

require 'code_structure/code_elem_parent'
require 'lang_file'
require 'x_c_t_e_plugin'

module XCTECSharp
  class ClassStandard < ClassBase
    def initialize
      @name = 'standard'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)

      classDec = cls.model.visibility + ' class ' + get_class_name(cls)

      for par in (0..cls.base_classes.size)
        if par == 0 && !cls.base_classes[par].nil?
          classDec << ' : ' << cls.base_classes[par].visibility << ' ' << cls.base_classes[par].name
        elsif !cls.base_classes[par].nil?
          classDec << ', ' << cls.base_classes[par].visibility << ' ' << cls.base_classes[par].name
        end
      end

      bld.start_class(classDec)

      # Process variables
      each_var(UtilsEachVarParams.new.wCls(cls).wSeparate(true).wVarCb(lambda { |var|
        XCTECSharp::Utils.instance.get_var_dec(var)
      }))

      bld.add if cls.functions.length > 0

      # Generate code for functions
      render_functions(cls, bld)

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTECSharp::ClassStandard.new)
