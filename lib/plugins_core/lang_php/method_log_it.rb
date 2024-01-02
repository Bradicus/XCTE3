##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a method for writing all information in
# this class to a stream

require 'plugins_core/lang_php/x_c_t_e_php'

class XCTEPhp::MethodLogIt < XCTEPlugin
  def initialize
    @name = 'method_log_it'
    @language = 'php'
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns definition string for this class's logIt method
  def get_definition(codeClass, outCode)
    outCode.indent

    outCode.add('/**')
    outCode.add("* Logs this class's info to a stream")
    outCode.add('*')
    outCode.add('* @param outStr The stream theis class is being logged to')
    outCode.add('* @param indent The amount we we indent each line in the class output')
    outCode.add('* @param logChildren Whether or not we will write objects side this object')
    outCode.add('* to the debug stream')
    outCode.add('*/')

    outCode.add('void logIt(fHandle, indent, logChildren)')
    outCode.add('{')

    outcode.indent

    if codeClass.hasAnArray
      outCode.add('int i;')
    end

    outCode.add('fwrite(fHandle, indent + " -- ' << codeClass.name << ' begin -- ");')

    varArray = []
    codeClass.getAllVarsFor(varArray)

    for varSec in varArray
      if varSec.elementId == CodeElem::ELEM_VARIABLE
        if !varSec.isPointer
          if varSec.arrayElemCount > 0
            if XCTECpp::Utils.is_primitive(varSec)
              outCode.add('fwrite(fHandle, indent + "' << varSec.name << ': ");')
              outCode.add('foreach (' << varSec.name << ' as ' << varSec.name << '__Item)')
              outCode.iadd(1, 'fwrite(fHandle, ' << varSec.name << '__Item + "  ");')
              outCode.iadd(1, 'fwrite(fHandle, "\"));')
            else
              outCode.iadd(1, 'fwrite(indent + "' << varSec.name << ': ");')

              outCode.add('if (logChildren)')
              outCode.add('{')
              outCode.iadd(1, 'foreach (' << varSec.name << ' as ' << varSec.name << '__Item)')
              outCode.iadd(2,    varSec.name << '__Item.logIt(outStr,  indent + "  ");')
              outCode.iadd(2,    'fwrite(fHandle, "\"));')
              outCode.add('}')
            end
          elsif XCTECpp::Utils.is_primitive(varSec) # Not an array
            outCode.add('fwrite(indent + "' << varSec.name << ': " + ' << varSec.name << ');')
          else
            outCode.add('fwrite(indent + "Object ' << varSec.name << ': ");')
            outCode.add('if (logChildren)')
            outCode.iadd(1, varSec.name << '.logIt(outStr,  indent + "  ");')
          end
        else
          # outCode.add("pStream.println(indent + " << varSec.name << ");")
        end
      elsif varSec.elementId == CodeElem::ELEM_COMMENT
        outCode.add(XCTEPhp::Utils.getComment(varSec))
      elsif varSec.elementId == CodeElem::ELEM_FORMAT
        outCode.add(varSec.formatText)
      end
    end

    outCode.add('fwrite(indent + " -- ' << codeClass.name << ' end -- ");')

    outCode.unindent

    outCode.add('}')

    outCode.unindent
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEPhp::MethodLogIt.new)
