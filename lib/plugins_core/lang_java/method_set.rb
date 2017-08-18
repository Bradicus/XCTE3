##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a read meathod for a class

require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_java/x_c_t_e_java.rb'

class XCTEJava::MethodSet < XCTEPlugin

  def initialize
    @name = "method_set"
    @language = "java"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's set method
  def get_definition(codeClass, cfg)
    defString = String.new
    varArray = Array.new
    codeClass.getAllVarsFor(varArray);

    for varSec in varArray
      if varSec.elementId == CodeElem::ELEM_VARIABLE && varSec.genSet == "true"
        if !varSec.isPointer
          if varSec.arrayElemCount == 0
            if XCTEJava::Utils::isPrimitive(varSec)
              defString << "        void set" << XCTEJava::Utils::getCapitalizedFirst(varSec.name)
              defString << "(" << XCTEJava::Utils::getTypeName(varSec.vtype) << " new" << XCTEJava::Utils::getCapitalizedFirst(varSec.name)
              defString << ")\t{ " << varSec.name << " = new" << XCTEJava::Utils::getCapitalizedFirst(varSec.name) << "; }\n"
            end
          end
        end

      elsif varSec.elementId == CodeElem::ELEM_COMMENT
        defString << "    " << XCTEJava::Utils::getComment(varSec)
      elsif varSec.elementId == CodeElem::ELEM_FORMAT
        defString << varSec.formatText
      end
    end

    return(defString);
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTEJava::MethodSet.new)
