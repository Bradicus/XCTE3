##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a get meathod for a class

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_java/x_c_t_e_java.rb"

class XCTEJava::MethodGet < XCTEPlugin
  def initialize
    @name = "method_get"
    @language = "java"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's get method
  def get_definition(codeClass, cfg)
    eachVar(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
      if var.genGet == "true" && !var.isPointer
        if Utils.instance.isPrimitive(var)
          bld.add(Utils.instance.getTypeName(var.vtype) << " get" << XCTEJava::Utils::getCapitalizedFirst(var.name))
          bld.sameLine("()\t{ return(" << var.name << "); }")
        end
      end
    }))
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodGet.new)
