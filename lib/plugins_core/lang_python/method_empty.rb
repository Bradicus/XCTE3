##

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
require 'plugins_core/lang_python/x_c_t_e_python.rb'

module XCTEPython
  class MethodEmpty < XCTEPlugin

    def initialize
      @name = "method_empty"
      @language = "python"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for an empty method
    def get_definition(dataModel, genClass, fun, rend)
      indent = String.new("    ")

      # Skeleton of comment block
      rend.add("#")
      rend.add("#")

      for param in fun.parameters.vars
        rend.add("# " << param.name << "::" )
      end

      if fun.returnValue.vtype != "void"
        rend.add("# ") 
        rend.add("# return:: ")
      end

      rend.startFunction("def " + Utils.instance.getStyledFunctionName(fun.name))

      # Function body framework
    
      rend.add("self." + Utils.instance.getStyledFunctionName(fun.name) + "(")

      for param in (0..(fun.parameters.vars.size - 1))
        if param != 0
          rend.sameLine(", ")
        end

        rend.sameLine(Utils.instance.getParamDec(fun.parameters.vars[param]))
      end

      rend.sameLine(")")
      rend.add

      if fun.returnValue.vtype != "void"
        rend.add(fun.returnValue.name)
      end

      rend.add("# " + fun.name)
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEPython::MethodEmpty.new)
