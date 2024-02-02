##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a method for writing all information in
# this class to a stream

require 'plugins_core/lang_java/x_c_t_e_java'

class XCTEJava::MethodLogIt < XCTEPlugin
  def initialize
    @name = 'method_log_it'
    @language = 'java'
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns definition string for this class's logIt method
  def render_function(cls, _cfg)
    logItString = String.new
    indent = String.new('')

    bld.add('/**' << indent << "* Logs this class's info to a stream")
    bld.add('* ')
    bld.add('* @param outStr The stream theis class is being logged to')
    bld.add('* @param indent The amount we we indent each line in the class output')
    bld.add('* @param logChildren Whether or not we will write objects side this object')
    bld.add('* to the debug stream')
    bld.add('*/')

    bld.add('void logIt(PrintStream pStream, String indent, boolean logChildren)')
    bld.add('{')

    if cls.has_an_array
      bld.add("int i;\n")
    end

    bld.add('pStream.println(indent + " -- ' << cls.name << ' begin -- ");')

    each_var(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
      if var.elementId == CodeElem::ELEM_VARIABLE
        if var.isPointer
          if var.arrayElemCount > 0
            if XCTECpp::Utils.is_primitive(var)
              bld.add('pStream.print(indent + "' << var.name << ': ");')
              bld.add('for (i = 0; i < ' << var.name + '.length; i++)')
              bld.add('pStream.print(' << var.name << '[i] + "  ");')
              bld.add("pStream.println();\n")
            else
              bld.add('pStream.println(indent + "' << var.name << ': ");')

              bld.start_block('if (logChildren)')
              bld.start_block('for (i = 0; i < ' << var.name + '.length; i++)')
              bld.add(var.name << "[i].logIt(outStr,  indent + \"  \");\n")
              bld.add('pStream.println();')
              bld.end_block
              bld.end_block
            end
          elsif XCTECpp::Utils.is_primitive(var) # Not an array
            bld.add('pStream.println(indent + "' << var.name << ': " + ' << var.name << ');')
          else
            bld.add('pStream.println(indent + "Object ' << var.name << ': ");')
            bld.start_block('if (logChildren)')
            bld.add(var.name << '.logIt(outStr,  indent + "  ");')
            bld.end_block
          end
        else
          # bld.add("pStream.println(indent + " << varSec.name << ");")
        end
      end
    }))

    bld.add('pStream.println(indent + " -- ' << cls.name << ' end -- ");')

    bld.end_block

    return logItString
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTEJava::MethodLogIt.new)
