##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an equality assignment operator for making
# a copy of a class

require 'x_c_t_e_plugin'
require 'plugins_core/lang_cpp/x_c_t_e_cpp'

module XCTECpp
  class XCTECpp::MethodOperatorEqualTo < XCTEPlugin
    def initialize
      @name = 'method_operator_equal_to'
      @language = 'cpp'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's equality assignment operator
    def get_declaration(cls, bld, _funItem)
      eqString = String.new

      bld.add('bool operator==' << '(const ' << cls.name)
      bld.sameLine(eqString << ' src' << cls.name << ') const;')

      return eqString
    end

    def process_dependencies(cls, bld, funItem)
    end

    # Returns definition string for this class's equality assignment operator
    def get_definition(cls, bld, _funItem)
      longArrayFound = false
      seperator = ''

      bld.add('/**')
      bld.add('* Sets this object equal to incoming object')
      bld.add('*/')
      bld.startClass('bool ' + cls.name + ' :: operator==' + '(const ' + cls.name + ' src' + cls.name + ') const')

      bld.add('return(')
      bld.indent

      # Process variables
      Utils.instance.eachVar(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.isStatic && Utils.instance.is_primitive(var) && (var.arrayElemCount.to_i == 0) # Array of primitives
          bld.add(seperator << Utils.instance.get_styled_variable_name(var) << ' == ')
          bld.sameLine('src' << cls.name << '.')
          bld.sameLine(Utils.instance.get_styled_variable_name(var))

          seperator = '&& '
        end
      }))

      bld.unindent

      bld.add(');')
      bld.endBlock
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodOperatorEqualTo.new)
