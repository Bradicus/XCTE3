##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a method for writing all information in
# this class to a stream

require "plugins_core/lang_cpp/x_c_t_e_cpp.rb"

module XCTECpp
  class XCTECpp::MethodLogIt < XCTEPlugin
    def initialize
      @name = "method_log_it"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's logIt method
    def get_declaration(cls, funItem, bld)
      bld.add("        void logIt(std::ostream &outStr, std::string indent, bool logChildren = false) const;")
    end

    def process_dependencies(cls, funItem, bld)
    end

    # Returns definition string for this class's logIt method
    def get_definition(cls, funItem, bld)
      bld.add("/**\n* Logs this class's info to a stream")
      bld.add("* ")
      bld.add("* @param outStr The stream theis class is being logged to")
      bld.add("* @param indent The amount we we indent each line in the class output")
      bld.add("* @param logChildren Whether or not we will write objects side this object")
      bld.add("* to the debug stream")
      bld.add("*/")

      bld.add("void " << cls.getUName() << " :: logIt(std::ostream &outStr, std::string indent, bool logChildren) const")
      bld.add("{")

      if cls.model.hasAnArray
        bld.add("    unsigned int i;")
      end

      bld.add("    outStr << indent << \" -- " << cls.getUName() << " begin -- \" << std::endl;")

      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      for varSec in varArray
        if varSec.elementId == CodeElem::ELEM_VARIABLE
          if !varSec.isPointer
            if varSec.arrayElemCount > 0
              if Utils.instance.isPrimitive(varSec)
                bld.add("    outStr << indent << \"" << varSec.name << ": \";")
                bld.add("\n    for (i = 0; i < " << Utils.instance.getSizeConst(varSec) << "; i++)")
                bld.add("        outStr << ")
                bld.add(varSec.name << "[i] << \"  \";")
                bld.add("    outStr << std::endl;\n")
              else
                bld.add("    outStr << indent << \"" << varSec.name << ": \";")

                bld.add("\n    if (logChildren) {")
                bld.add("        for (i = 0; i < " << Utils.instance.getSizeConst(varSec) + "; i++)")
                bld.add("            " << varSec.name << "[i].logIt(outStr,  indent + \"  \");\n")
                bld.add("        outStr << std::endl;\n")
              end
            else # Not an array
              if Utils.instance.isPrimitive(varSec)
                bld.add("    outStr << indent << \"" << varSec.name << ": \" << ")
                bld.add(varSec.name + " << std::endl;")
              else
                bld.add("    outStr << indent << \"Object " << varSec.name << ": \";")
                bld.add("\n    if (logChildren) {")
                bld.add("        " << varSec.name << ".logIt(outStr,  indent + \"  \");")
              end
            end
          else
            bld.add("    outStr << indent << " << varSec.name << " << std::endl;")
          end
        elsif varSec.elementId == CodeElem::ELEM_COMMENT
          bld.add("    " + Utils.instance.getComment(varSec))
        elsif varSec.elementId == CodeElem::ELEM_FORMAT
          bld.add(varSec.formatText)
        end

        bld.add("    outStr << indent << \" -- " << cls.getUName() << " end -- \" << std::endl;")

        bld.add("}")
      end
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodLogIt.new)
