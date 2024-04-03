##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'x_c_t_e_plugin'
require 'plugins_core/lang_cpp/x_c_t_e_cpp'

module XCTECpp
  class MethodConstructor < XCTEPlugin
    def initialize
      @name = 'method_constructor'
      @language = 'cpp'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's constructor
    def get_declaration(cls, bld, _funItem)
      bld.add(Utils.instance.style_as_class(cls.get_u_name) + '();')
    end

    # Returns declairation string for this class's constructor
    def get_declaration_inline(cls, bld, funItem)
      bld.startFuction(Utils.instance.style_as_class(cls.get_u_name) + '()')
      codeStr << get_body(cls, funItem, hFile)
      bld.endFunction
    end

    def process_dependencies(cls, bld, funItem); end

    # Returns definition string for this class's constructor
    def render_function(cls, bld, funItem)
      bld.add('/**')
      bld.add('* Constructor')
      bld.add('*/')

      classDef = String.new
      classDef << Utils.instance.style_as_class(cls.get_u_name) << ' :: ' << Utils.instance.style_as_class(cls.get_u_name) << '()'
      bld.start_class(classDef)

      get_body(cls, bld, funItem)

      bld.endFunction
    end

    def get_body(cls, bld, _funItem)
      conDef = String.new

      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.defaultValue.nil?
          bld.add(Utils.instance.get_styled_variable_name(var) << ' = ')

          if var.vtype == 'String'
            bld.same_line('"' << var.defaultValue << '";')
          else
            bld.same_line(var.defaultValue << ';')
          end

          bld.same_line("\t// " << var.comment) if !var.comment.nil?

          bld.add
        end

        bld.add(var.init) if !var.init.nil?
      }))
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodConstructor.new)
