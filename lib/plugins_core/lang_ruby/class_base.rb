require "plugins_core/lang_ruby/utils.rb"
require "x_c_t_e_plugin.rb"

# This class contains functions that may be usefull in any type of class
module XCTERuby
  class ClassBase < XCTEPlugin
    def startNamespaces(cls, bld)
      for ns in cls.namespaceList
        bld.startBlock("module " + ns)
      end
    end

    def endNamespaces(cls, bld)
      for ns in cls.namespaceList
        bld.endBlock
      end
    end
  end
end
