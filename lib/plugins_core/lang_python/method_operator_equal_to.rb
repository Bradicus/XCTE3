##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an equality assignment operator for making
# a copy of a class

require 'plugins_core/lang_python/x_c_t_e_python'
require 'plugins_core/lang_python/utils'

module XCTEPython
  class MethodOperatorEqualTo < XCTEPlugin
    def initialize
      @name = 'method_operator_equal_to'
      @language = 'python'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's equality assignment operator
    def render_function(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec

      longArrayFound = false
      seperator = ''

      bld.add "# Compares two object for equality\n"

      bld.add 'def __eq__' << '(src' << Utils.instance.style_as_file_name(cls.get_u_name) << ')'

      bld.add "    return(\n"

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && !var.isStatic && Utils.instance.is_primitive(var) && (var.arrayElemCount.to_i == 0)	# Array of primitives
          bld.add '        ' << seperator << '@' << var.name << ' == '
          bld.add 'src' << Utils.instance.style_as_file_name(cls.get_u_name) << '.'
          bld.add var.name

          seperator = '&& '
        end
      }))

      bld.add "    )\n"
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEPython::MethodOperatorEqualTo.new)
