require "plugins_core/lang_typescript/utils.rb"
require "x_c_t_e_plugin.rb"

# This class contains functions that may be usefull in any type of class
module XCTETypescript
  class ClassBase < XCTEPlugin
    def process_dependencies(cls, cfg, bld)
      for inc in cls.includes
        bld.add("import { " + inc.name + " } from '" + inc.path + "';")
      end
    end
  end
end
