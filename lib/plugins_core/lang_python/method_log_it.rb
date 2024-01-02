##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a method for writing all information in
# this class to a stream

require 'plugins_core/lang_python/x_c_t_e_python'

class XCTEPython::MethodLogIt < XCTEPlugin
  def initialize
    @name = 'method_log_it'
    @language = 'python'
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns definition string for this class's logIt method
  def get_definition(codeClass, _cfg)
    logItString = String.new
    indent = String.new('')

    logItString << indent << "# Logs this class's info to a stream\n"
    logItString << indent << "# \n"
    logItString << indent << "# outStr:: The stream theis class is being logged to\n"
    logItString << indent << "# indent:: The amount we we indent each line in the class output\n"
    logItString << indent << "# logChildren:: Whether or not we will write objects side this object\n"
    logItString << indent << "# to the debug stream\n"

    logItString << indent << "def logIt(pStream, indent, logChildren)\n"

    logItString << indent << '    pStream << indent << " -- ' << codeClass.name << " begin -- \"\n"

    varArray = []
    codeClass.getAllVarsFor(varArray)

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
        if var.isPointer
          if var.arrayElemCount > 0
            if XCTECpp::Utils.is_primitive(var)
              logItString << indent << '    pStream << indent << "' << var.name << ": \"\n"
              logItString << indent << '    for ' << var.name << 'Item in self.' << var.name << "\n"
              logItString << indent << '        pStream << ' << var.name << "Item << \"  \"\n"
              logItString << indent << "    pStream << \"\\n\";\n\n"
            else
              logItString << indent << '    pStream << indent << "' << var.name << ': "'

              logItString << indent << "    if (logChildren)\n"
              logItString << indent << '        for ' << var.name << 'Item in self.' << var.name << "\n"
              logItString << indent << '            ' << var.name << "Item.logIt(outStr,  indent + \"  \"\n"
              logItString << indent << "    pStream << \"\\n\"\n\n"
            end
          elsif XCTECpp::Utils.is_primitive(var) # Not an array
            logItString << indent << '    pStream << indent << "' << var.name << ': " << self.' << var.name << "\n"
          else
            logItString << indent << '    pStream.println(indent + "Object ' << var.name << ': "'
            logItString << indent << "    if (logChildren)\n"
            logItString << indent << '        self.' << var.name << ".logIt(outStr,  indent + \"  \"\n"
          end
        else
          logItString << indent << '    pStream << indent << self.' << var.name << "\n"
        end
      elsif var.elementId == CodeElem::ELEM_COMMENT
        logItString << indent << '    ' << XCTEPython::Utils.getComment(var)
      elsif var.elementId == CodeElem::ELEM_FORMAT
        logItString << indent << var.formatText
      end
    end

    logItString << indent << '    pStream << indent << " -- ' << codeClass.name << " end -- \"\n"

    return logItString
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEPython::MethodLogIt.new)
