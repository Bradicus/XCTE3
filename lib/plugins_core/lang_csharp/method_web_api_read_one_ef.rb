##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'x_c_t_e_plugin'
require 'code_name_styling'
require 'plugins_core/lang_csharp/utils'

module XCTECSharp
  class MethodWebApiReadOneEF < XCTEPlugin
    def initialize
      @name = 'method_web_api_read_one_ef'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def render_function(cls, bld, fun)
      bld.add('///')
      bld.add('/// Web API get single ' + cls.get_u_name)
      bld.add('///')

      bld.start_function('public ' + Utils.instance.style_as_class(cls.get_u_name) + ' Get' + Utils.instance.style_as_class(cls.get_u_name) + '(int id)')

      get_body(cls, bld, fun)

      bld.endFunction
    end

    def get_declairation(cls, bld, _fun)
      bld.add('public ' + Utils.instance.style_as_class(cls.get_u_name) +
              ' Get' + Utils.instance.style_as_class(cls.get_u_name) + '(int id);')
    end

    def process_dependencies(cls, _bld, _fun)
      cls.addUse('System.Collections.Generic', 'List')
      cls.addUse('System.Web.Http', 'ApiController')
    end

    def get_body(cls, bld, _fun)
      conDef = String.new
      varArray = []
      cls.model.getAllVarsFor(varArray)

      bld.add(cls.data_node)

      bld.end_block
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECSharp::MethodWebApiReadOneEF.new)
