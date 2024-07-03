##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a method for writing all information in
# this class to a stream

require "plugins_core/lang_cpp/x_c_t_e_cpp"

module XCTECpp
  class XCTECpp::MethodLogIt < XCTEPlugin
    def initialize
      @name = "method_log_it"
      @language = "cpp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's logIt method
    def render_declaration(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec

      bld.add("        void logIt(std::ostream &outStr, std::string indent, bool logChildren = false) const;")
    end

    def process_dependencies(cls, funItem)
    end

    # Returns definition string for this class's logIt method
    def render_function(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec

      bld.add("/**\n* Logs this class's info to a stream")
      bld.add("* ")
      bld.add("* @param outStr The stream theis class is being logged to")
      bld.add("* @param indent The amount we we indent each line in the class output")
      bld.add("* @param logChildren Whether or not we will write objects side this object")
      bld.add("* to the debug stream")
      bld.add("*/")

      bld.add("void " << cls.get_u_name() << " :: logIt(std::ostream &outStr, std::string indent, bool logChildren) const")
      bld.add("{")

      if cls.model.has_an_array
        bld.add("    unsigned int i;")
      end

      bld.add('    outStr << indent << " -- ' << cls.get_u_name() << ' begin -- " << std::endl;')

      varArray = []
      cls.model.getAllVarsFor(varArray)

      for varSec in varArray
        if varSec.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
          if !varSec.isPointer
            if varSec.arrayElemCount > 0
              if Utils.instance.is_primitive(varSec)
                bld.add('    outStr << indent << "' << varSec.name << ': ";')
                bld.add("\n    for (i = 0; i < " << Utils.instance.get_size_const(varSec) << "; i++)")
                bld.add("        outStr << ")
                bld.add(varSec.name << '[i] << "  ";')
                bld.add("    outStr << std::endl;\n")
              else
                bld.add('    outStr << indent << "' << varSec.name << ': ";')

                bld.add("\n    if (logChildren) {")
                bld.add("        for (i = 0; i < " << Utils.instance.get_size_const(varSec) + "; i++)")
                bld.add("            " << varSec.name << "[i].logIt(outStr,  indent + \"  \");\n")
                bld.add("        outStr << std::endl;\n")
              end
            elsif Utils.instance.is_primitive(varSec) # Not an array
              bld.add('    outStr << indent << "' << varSec.name << ': " << ')
              bld.add(varSec.name + " << std::endl;")
            else
              bld.add('    outStr << indent << "Object ' << varSec.name << ': ";')
              bld.add("\n    if (logChildren) {")
              bld.add("        " << varSec.name << '.logIt(outStr,  indent + "  ");')
            end
          else
            bld.add("    outStr << indent << " << varSec.name << " << std::endl;")
          end
        elsif varSec.element_id == CodeStructure::CodeElemTypes::ELEM_COMMENT
          bld.add("    " + Utils.instance.get_comment(varSec))
        elsif varSec.element_id == CodeStructure::CodeElemTypes::ELEM_FORMAT
          bld.add(varSec.formatText)
        end

        bld.add('    outStr << indent << " -- ' << cls.get_u_name() << ' end -- " << std::endl;')

        bld.add("}")
      end
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodLogIt.new)
