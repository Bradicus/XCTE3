##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a destructor for a class

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_cpp/x_c_t_e_cpp.rb"

class XCTECpp::MethodDestructor < XCTEPlugin
  def initialize
    @name = "method_destructor"
    @language = "cpp"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's destructor
  def render_declaration(fp_params)
    bld = fp_params.bld
    cls = fp_params.cls_spec
    bld.add "        ~" << cls.name << "();\n"
  end

  # Returns declairation string for this class's destructor
  def render_declaration_inline(fp_params)
    bld = fp_params.bld
    cls = fp_params.cls_spec
    bld.add "        ~" << cls.name << "() {};\n"
  end

  # Returns definition string for this class's destructor
  def render_function(fp_params)
    bld = fp_params.bld
    cls = fp_params.cls_spec

    bld.add "/**\n"
    bld.add "* Destructor\n"
    bld.add "*/\n"

    bld.add cls.name + " :: ~" << cls.name << "()\n"
    bld.add "{\n"
    bld.add "}\n\n"
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodDestructor.new)
