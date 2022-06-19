##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an empty method with the specified function name
# and parameters

require "code_elem_model.rb"
require "lang_file.rb"

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_cpp/x_c_t_e_cpp.rb"

module XCTECpp
  class MethodEmpty < XCTEPlugin
    def initialize
      @name = "method_empty"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this empty method
    def get_declaration(cls, fun, hFile)
      eDecl = String.new

      if fun.isVirtual
        eDecl << "virtual "
      end

      if fun.isStatic
        eDecl << "static "
      end

      if fun.returnValue.isConst
        eDecl << "const "
      end

      eDecl << Utils.instance.getTypeName(fun.returnValue) << " "
      eDecl << fun.name << "("

      for param in (0..(fun.parameters.vars.size - 1))
        if param != 0
          eDecl << ", "
        end

        eDecl << Utils.instance.getParamDec(fun.parameters.vars[param])
      end

      eDecl << ")"

      if fun.isConst
        eDecl << " const"
      end

      eDecl << ";"

      hFile.add(eDecl)
    end

    # Returns definition string for an empty method
    def get_definition(cls, fun, codeBuilder)

      # Skeleton of comment block
      codeBuilder.add("/**")
      codeBuilder.add("* ")
      codeBuilder.add("* ")

      for param in fun.parameters.vars
        codeBuilder.add("* @param " + Utils.instance.getStyledVariableName(param))
      end

      if fun.returnValue.vtype != "void"
        codeBuilder.add("*")
        codeBuilder.add("* @return ")
      end

      codeBuilder.add("*/ ")

      funDec = String.new

      # Function body framework
      if fun.returnValue.isConst
        funDec << "const "
      end

      funDec << Utils.instance.getTypeName(fun.returnValue) + " "
      funDec << Utils.instance.getStyledClassName(cls.model.name) + " :: "
      funDec << Utils.instance.getStyledFunctionName(fun.name) << "("

      for param in (0..(fun.parameters.vars.size - 1))
        if param != 0
          funDec << ", "
        end

        funDec << Utils.instance.getParamDec(fun.parameters.vars[param])
      end

      funDec << ")"

      if fun.isConst
        funDec << " const"
      end

      codeBuilder.startFunction(funDec)

      if fun.returnValue.vtype != "void"
        codeBuilder.add("return();")
      end

      codeBuilder.endFunction()
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodEmpty.new)
