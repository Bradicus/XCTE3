##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin"

module XCTECSharp
  class MethodEFConfiguration < XCTEPlugin
    def initialize
      @name = "method_ef_configuration"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def render_function(fp_params)
      bld = fp_params.bld
      cls = fp_params.cls_spec
      fun = fp_params.fun_spec
      bld.add("//")
      bld.add("// Configuration ")
      bld.add("//")

      entityClassName = XCTECSharp::Utils.instance.style_as_class(cls.get_u_name)
      configFunName = "Configure(EntityTypeBuilder<" + entityClassName + "> builder)"

      bld.start_function("public void " + configFunName)

      get_body(cls, bld, fun)

      bld.endFunction
    end

    def get_body(cls, bld, _fun)
      bld.add('builder.ToTable("' + XCTETSql::Utils.instance.style_as_class(cls.get_u_name) + '", "dbo");')

      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.genGet || var.genSet
          bld.add("builder.Property(e => e." + XCTECSharp::Utils.instance.style_as_function(var.name) + ")")
        else
          bld.add("builder.Property(e => e." + XCTECSharp::Utils.instance.get_styled_variable_name(var.name) + ")")
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
