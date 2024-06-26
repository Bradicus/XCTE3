##
# Class:: Standard
# Author:: Brad Ottoson
#

require "plugins_core/lang_csharp/utils"
require "plugins_core/lang_csharp/source_renderer_csharp"

require "code_structure/code_elem_parent"
require "lang_file"
require "x_c_t_e_plugin"

module XCTECSharp
  class XCTECSharp::TestEngine < ClassBase
    def initialize
      @name = "test_engine"
      @language = "csharp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name + " engine"
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      templ = PluginManager.find_method_plugin("csharp", "method_test_engine")

      bld.add("[TestClass]")
      classDec = cls.model.visibility + " class " + Utils.instance.style_as_class(cls.get_u_name)

      bld.start_class(classDec)

      # Process variables
      each_var(UtilsEachVarParams.new.wCls(cls).wSeparate(true).wVarCb(lambda { |var|
        XCTECSharp::Utils.instance.get_var_dec(var)
      }))

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTECSharp::TestEngine.new)
