require 'plugins_core/lang_typescript/utils'
require 'x_c_t_e_plugin'

# This class contains functions that may be usefull in any type of class
module XCTETypescript
  class PluginBase < XCTEPlugin
    def style_as_file_name(uName)
      return Utils.instance.style_as_file_name(uName)
    end

    def style_as_class(uName)
      return Utils.instance.style_as_class(uName)
    end
  end
end
