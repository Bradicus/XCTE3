##

#
# Copyright (C) 2008 Brad Ottoson
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
    def get_declaration(cls, funItem, codeBuilder)
      codeBuilder.add("        void logIt(std::ostream &outStr, std::string indent, bool logChildren = false) const;")
    end

    def get_dependencies(cls, funItem, codeBuilder)
    end

    # Returns definition string for this class's logIt method
    def get_definition(cls, funItem, codeBuilder)
      codeBuilder.add("/**\n* Logs this class's info to a stream")
      codeBuilder.add("* ")
      codeBuilder.add("* @param outStr The stream theis class is being logged to")
      codeBuilder.add("* @param indent The amount we we indent each line in the class output")
      codeBuilder.add("* @param logChildren Whether or not we will write objects side this object")
      codeBuilder.add("* to the debug stream")
      codeBuilder.add("*/")

      codeBuilder.add("void " << cls.model.name << " :: logIt(std::ostream &outStr, std::string indent, bool logChildren) const")
      codeBuilder.add("{")

      if cls.model.hasAnArray
        codeBuilder.add("    unsigned int i;")
      end

      codeBuilder.add("    outStr << indent << \" -- " << cls.model.name << " begin -- \" << std::endl;")

      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      for varSec in varArray
        if varSec.elementId == CodeElem::ELEM_VARIABLE
          if !varSec.isPointer
            if varSec.arrayElemCount > 0
              if Utils.instance.isPrimitive(varSec)
                codeBuilder.add("    outStr << indent << \"" << varSec.name << ": \";")
                codeBuilder.add("\n    for (i = 0; i < " << Utils.instance.getSizeConst(varSec) << "; i++)")
                codeBuilder.add("        outStr << ")
                codeBuilder.add(varSec.name << "[i] << \"  \";")
                codeBuilder.add("    outStr << std::endl;\n")
              else
                codeBuilder.add("    outStr << indent << \"" << varSec.name << ": \";")

                codeBuilder.add("\n    if (logChildren) {")
                codeBuilder.add("        for (i = 0; i < " << Utils.instance.getSizeConst(varSec) + "; i++)")
                codeBuilder.add("            " << varSec.name << "[i].logIt(outStr,  indent + \"  \");\n")
                codeBuilder.add("        outStr << std::endl;\n")
              end
            else # Not an array
              if Utils.instance.isPrimitive(varSec)
                codeBuilder.add("    outStr << indent << \"" << varSec.name << ": \" << ")
                codeBuilder.add(varSec.name + " << std::endl;")
              else
                codeBuilder.add("    outStr << indent << \"Object " << varSec.name << ": \";")
                codeBuilder.add("\n    if (logChildren) {")
                codeBuilder.add("        " << varSec.name << ".logIt(outStr,  indent + \"  \");")
              end
            end
          else
            codeBuilder.add("    outStr << indent << " << varSec.name << " << std::endl;")
          end
        elsif varSec.elementId == CodeElem::ELEM_COMMENT
          codeBuilder.add("    " + Utils.instance.getComment(varSec))
        elsif varSec.elementId == CodeElem::ELEM_FORMAT
          codeBuilder.add(varSec.formatText)
        end

        codeBuilder.add("    outStr << indent << \" -- " << cls.model.name << " end -- \" << std::endl;")

        codeBuilder.add("}")
      end
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECpp::MethodLogIt.new)
