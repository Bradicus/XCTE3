##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'plugins_core/lang_ruby/utils'
require 'plugins_core/lang_ruby/class_base'
require 'plugins_core/lang_ruby/x_c_t_e_ruby.rb'

module XCTERuby
  class MethodConstructor < ClassBase

    def initialize
      super 
      @name = "method_constructor"
      @language = "ruby"
      @category = XCTEPlugin::CAT_METHOD
    end

    def get_unformatted_class_name(cls)
      cls.getUName
    end

    # Returns the code for the content for this function
    def render_function(cls, bld, fun)
      param_str = ''

      for param in fun.parameters.vars
        param_str += get_default_utils().get_param_dec(param)
      end

      bld.start_class("def initialize(" + param_str + ")")

      each_var(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
      }))

      bld.end_class
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTERuby::MethodConstructor.new)
