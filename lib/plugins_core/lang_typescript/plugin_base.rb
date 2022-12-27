require "plugins_core/lang_typescript/utils.rb"
require "x_c_t_e_plugin.rb"

# This class contains functions that may be usefull in any type of class
module XCTETypescript
  class PluginBase < XCTEPlugin
    def getStyledFileName(uName)
      return Utils.instance.getStyledFileName(uName)
    end

    def getStyledClassName(uName)
      return Utils.instance.getStyledClassName(uName)
    end
  end
end
