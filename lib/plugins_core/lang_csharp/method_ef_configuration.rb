##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require 'x_c_t_e_plugin'

module XCTECSharp
  class MethodEFConfiguration < XCTEPlugin
    def initialize
      @name = 'method_ef_configuration'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def render_function(cls, bld, fun)
      bld.add('//')
      bld.add('// Configuration ')
      bld.add('//')

      entityClassName = XCTECSharp::Utils.instance.get_styled_class_name(cls.getUName)
      configFunName = 'Configure(EntityTypeBuilder<' + entityClassName + '> builder)'

      bld.start_function('public void ' + configFunName)

      get_body(cls, bld, fun)

      bld.endFunction
    end

    def get_body(cls, bld, _fun)
      bld.add('builder.ToTable("' + XCTETSql::Utils.instance.get_styled_class_name(cls.getUName) + '", "dbo");')

      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.genGet || var.genSet
          bld.add('builder.Property(e => e.' + XCTECSharp::Utils.instance.get_styled_function_name(var.name) + ')')
        else
          bld.add('builder.Property(e => e.' + XCTECSharp::Utils.instance.get_styled_variable_name(var.name) + ')')
        end

        bld.indent
        bld.add('.HasColumnName("' + XCTETSql::Utils.instance.get_styled_variable_name(var) + '");')
        bld.unindent

        bld.add
      }))
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTECSharp::MethodEFConfiguration.new)
