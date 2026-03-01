##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'x_c_t_e_plugin'
require 'plugins_core/lang_python/x_c_t_e_python'

module XCTEPython
  class MethodConstructor < XCTEPlugin
    def initialize
      super
      @name = 'method_constructor'
      @language = 'python'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def render_function(fp_params)
      bld = fp_params.bld
      bld.add('# Initializer')

      bld.start_function('def __init__(self)')

      get_body(fp_params)

      bld.endFunction
    end

    def get_body(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec

      conDef = String.new

      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && var.isStatic != true
          if !var.defaultValue.nil?
            bld.add('self.' << Utils.instance.get_styled_variable_name(var) + ' = ')

            if var.vtype == 'String'
              bld.same_line('"' + var.defaultValue.gsub('::', '.') + '"')
            else
              bld.same_line(var.defaultValue.gsub('::', '.'))
            end

            if !var.comment.nil?
              bld.same_line("\t# " + var.comment)
            end

            bld.add
          elsif !var.templates.empty? && (var.templates.include?('set') || var.templates.include?('list'))
            bld.add('self.' << Utils.instance.get_styled_variable_name(var) + ' = []')
          else
            bld.add('self.' << Utils.instance.get_styled_variable_name(var) + ' = None')
          end
        end
      }))
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEPython::MethodConstructor.new)
