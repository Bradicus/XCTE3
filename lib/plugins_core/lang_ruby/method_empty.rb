##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an empty method with the specified function name
# and parameters

require 'code_elem_model.rb'
require 'lang_file.rb'

require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_ruby/x_c_t_e_ruby.rb'

class XCTERuby::MethodEmpty < XCTEPlugin

  def initialize
    @name = "method_empty"
    @language = "ruby"
    @category = XCTEPlugin::CAT_METHOD
    @author = "Brad Ottoson"
  end

  # Returns definition string for an empty method
  def get_definition(fun, cfg)
    eDef = String.new

    indent = String.new("    ")

    # Skeleton of comment block
    eDef << indent << "#\n"
    eDef << indent << "#\n"

    for param in fun.parameters
      eDef << indent << "# " << param.name << ":: \n"
    end

    if fun.returnValue.vtype != "void"
      eDef << indent << "# \n" << indent << "# return:: \n"
    end

    eDef << indent << "def "

    # Function body framework
    if fun.isStatic
      eDef << "self."
    end

    eDef << fun.name << "("

    for param in (0..(fun.parameters.size - 1))
      if param != 0
        eDef << ", "
      end

      eDef << XCTERuby::Utils::getParamDec(fun.parameters[param])
    end

    eDef << ")"

    eDef << "\n"

    eDef << indent << "    \n"

    if fun.returnValue.vtype != "void"
      eDef << indent << "    return \n"
    end

    eDef << indent << "end  # " << fun.name << "\n\n"

    return eDef
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTERuby::MethodEmpty.new)
