##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_ruby/x_c_t_e_ruby.rb'

class XCTERuby::MethodConstructor < XCTEPlugin

  def initialize
    @name = "method_constructor"
    @language = "ruby"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns definition string for this class's constructor
  def get_definition(codeClass, cfg)
    conDef = String.new
    indent = "    "

    conDef << indent << "# Constructor\n"

    conDef << indent << "def initialize()\n"

    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if var.defaultValue != nil
          conDef << indent << "    @" << var.name << " = "

          if var.vtype == "String"
            conDef << "\"" << var.defaultValue << "\""
          else
            conDef << var.defaultValue << ""
          end

          if var.comment != nil
            conDef << "\t# " << var.comment
          end

          conDef << "\n"
        end
      end
    end

    conDef << indent << "end  # initialize\n\n";

    return(conDef);
  end

end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTERuby::MethodConstructor.new)
