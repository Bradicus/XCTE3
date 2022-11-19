##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a constructor for a class

require "x_c_t_e_plugin.rb"

module XCTECSharp
  class MethodEFConfiguration < XCTEPlugin
    def initialize
      @name = "method_ef_configuration"
      @language = "csharp"
      @category = XCTEPlugin::CAT_METHOD
    end

    # Returns definition string for this class's constructor
    def get_definition(cls, fun, cfg, bld)
      bld.add("//")
      bld.add("// Configuration ")
      bld.add("//")

      entityClassName = XCTECSharp::Utils.instance.getStyledClassName(cls.getUName())
      configFunName = "Configure(EntityTypeBuilder<" + entityClassName + "> builder)"

      bld.startFunction("public void " + configFunName)

      get_body(cls, fun, cfg, bld)

      bld.endFunction
    end

    def get_body(cls, genFun, cfg, bld)
      bld.add('builder.ToTable("' + XCTETSql::Utils.instance.getStyledClassName(cls.getUName()) + '", "dbo");')

      # Process variables
      Utils.instance.eachVar(cls, bld, true, lambda { |var|
        if var.elementId == CodeElem::ELEM_VARIABLE
          if var.genGet || var.genSet
            bld.add("builder.Property(e => e." + XCTECSharp::Utils.instance.getStyledFunctionName(var.name) + ")")
          else
            bld.add("builder.Property(e => e." + XCTECSharp::Utils.instance.getStyledVariableName(var.name) + ")")
          end

          bld.indent
          bld.add('.HasColumnName("' + XCTETSql::Utils.instance.getStyledVariableName(var) + '");')
          bld.unindent

          bld.add
        end
      })
    end
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodEFConfiguration.new)
