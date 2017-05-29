##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a get meathod for a class

require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_java/x_c_t_e_java.rb'

class XCTEJava::MethodGet < XCTEPlugin

  def initialize
    @name = "method_get"
    @language = "java"
    @category = XCTEPlugin::CAT_METHOD
    @author = "Brad Ottoson"
  end

  # Returns declairation string for this class's get method
  def get_definition(codeClass, cfg)
    readDef = String.new
    varArray = Array.new
    codeClass.getAllVarsFor(cfg, varArray);

    for varSec in varArray
      if varSec.elementId == CodeElem::ELEM_VARIABLE && varSec.genGet == "true"
        if !varSec.isPointer
          if varSec.arrayElemCount == 0
            if XCTEJava::Utils::isPrimitive(varSec)
              readDef << "        " << XCTEJava::Utils::getTypeName(varSec.vtype) << " get" << XCTEJava::Utils::getCapitalizedFirst(varSec.name)
              readDef << "()\t{ return(" << varSec.name << "); }\n"
            end
          end
        end

      elsif varSec.elementId == CodeElem::ELEM_COMMENT
        readDef << "    " << XCTEJava::Utils::getComment(varSec)
      elsif varSec.elementId == CodeElem::ELEM_FORMAT
        readDef << varSec.formatText
      end
    end

    return(readDef);
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodGet.new)
