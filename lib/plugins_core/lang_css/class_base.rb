require "plugins_core/lang_css/utils.rb"
require "x_c_t_e_class_base.rb"

# This class contains functions that may be usefull in any type of class
module XCTECss
  class ClassBase < XCTEClassBase
    def get_default_utils
      return Utils.instance
    end
    
    def get_source_renderer()
      return SourceRendererBraceDelim.new 
    end

    def render_namespace_start(cls, bld)
    end
  
    def render_namespace_end(cls, bld)
    end
      
    def render_dependencies(cls, bld)
    end
  end
end
