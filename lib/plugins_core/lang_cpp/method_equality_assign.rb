##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates an equality assignment operator for making
# a copy of a class

require 'plugins_core/lang_cpp/x_c_t_e_cpp'

module XCTECpp
  class MethodEqualityAssign < XCTEPlugin
    def initialize
      @name = 'method_equality_assign'
      @language = 'cpp'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns declairation string for this class's equality assignment operator
    def get_declaration(cls, bld, _funItem)
      eqString = String.new

      bld.add(Utils.instance.get_styled_class_name(cls.get_u_name))
      bld.same_line('(const ' + Utils.instance.get_styled_class_name(cls.get_u_name))
      bld.same_line('& src' + Utils.instance.get_styled_class_name(cls.get_u_name) + ');')

      bld.add('const ' + Utils.instance.get_styled_class_name(cls.get_u_name))
      bld.same_line('& operator=' + '(const ' + Utils.instance.get_styled_class_name(cls.get_u_name))
      bld.same_line('& src' + Utils.instance.get_styled_class_name(cls.get_u_name) + ");\n")
    end

    def process_dependencies(cls, bld, funItem); end

    # Returns definition string for this class's equality assignment operator
    def render_function(cls, bld, _funItem)
      eqString = String.new
      longArrayFound = false

      styledCName = Utils.instance.get_styled_class_name(cls.get_u_name)

      # First add copy constructor
      bld.genMultiComment(['Copy constructor'])
      bld.start_function(styledCName + ' :: ' + styledCName + '(const ' + styledCName + '& src' + styledCName + ')')
      bld.add('operator=(src' + styledCName + ');')
      bld.endFunction

      bld.genMultiComment(['Sets this object equal to incoming object'])
      bld.add('const ' + styledCName)
      bld.same_line('& ' + styledCName + ' :: operator=' + '(const ' + styledCName)
      bld.same_line('& src' + styledCName + ')')
      bld.add('{')
      bld.indent

      #    if cls.has_an_array
      #      bld.add("    unsigned int i;"))
      #    end

      for par in cls.base_classes
        bld.add(Utils.instance.get_styled_class_name(par.name) + '::operator=(src' + styledCName + ');')
      end

      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        fmtVarName = Utils.instance.get_styled_variable_name(var)
        if !var.isStatic # Ignore static variables
          if Utils.instance.is_primitive(var)
            if var.arrayElemCount.to_i > 0 # Array of primitives
              bld.add('memcpy(' + fmtVarName + ', ' + 'src' + styledCName + '.' + fmtVarName + ', ')
              bld.same_line('sizeof(' + Utils.instance.get_type_name(var) + ') * ' + Utils.instance.get_size_const(var))
              bld.same_line(');')
            else
              bld.add(fmtVarName + ' = ' + 'src' + styledCName + '.')
              bld.same_line(fmtVarName + ';')
            end
          elsif var.arrayElemCount > 0 # Not a primitive
            if !longArrayFound
              bld.add('    unsigned int i;')
              longArrayFound = true
            end
            bld.add('for (i = 0; i < ' + Utils.instance.get_size_const(var) + '; i++)')
            bld.indent
            bld.add(fmtVarName + '[i] = ')
            bld.same_line('src' + styledCName + '.')
            bld.same_line(fmtVarName + "[i];\n")
            bld.unindent # Array of objects
          else
            bld.add(fmtVarName + ' = src' + styledCName + '.' + fmtVarName + ';')
          end
        end
      }))

      bld.add('return(*this);')
      bld.endFunction
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECpp::MethodEqualityAssign.new)
