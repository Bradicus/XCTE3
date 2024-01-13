require 'plugins_core/lang_typescript/utils'
require 'x_c_t_e_plugin'

# This class contains functions that may be usefull in any type of class
module XCTETypescript
  class PluginBase < XCTEPlugin
    def get_styled_file_name(uName)
      return Utils.instance.get_styled_file_name(uName)
    end

    def get_styled_class_name(uName)
      return Utils.instance.get_styled_class_name(uName)
    end
  end
end
