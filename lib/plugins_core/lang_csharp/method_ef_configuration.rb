##

# 
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This plugin creates a constructor for a class
 
require 'x_c_t_e_plugin.rb'

class XCTECSharp::MethodEFConfiguration < XCTEPlugin
  
  def initialize
    @name = "method_ef_configuration"
    @language = "csharp"
    @category = XCTEPlugin::CAT_METHOD
  end
  
  # Returns definition string for this class's constructor
  def get_definition(dataModel, genClass, fun, cfg, codeBuilder)
    codeBuilder.add("//")
    codeBuilder.add("// Configuration ")
    codeBuilder.add("//")

    entityClassName = XCTECSharp::Utils.instance.getStyledClassName(dataModel.name)
    configFunName = 'Configure(EntityTypeBuilder<' + entityClassName + '> builder)'

    codeBuilder.startFunction('public void ' + configFunName)

    get_body(dataModel, genClass, fun, cfg, codeBuilder)
        
    codeBuilder.endFunction
  end
  
  # No deps
  def get_dependencies(dataModel, genClass, genFun, cfg, codeBuilder)
  end

  def get_body(dataModel, genClass, genFun, cfg, codeBuilder)
    varArray = Array.new
    dataModel.getAllVarsFor(varArray);

    codeBuilder.add('builder.ToTable("' + XCTETSql::Utils.instance.getStyledClassName(dataModel.name) + '", "dbo");')

    for var in varArray
      if var.elementId == CodeElem::ELEM_VARIABLE
          codeBuilder.add('builder.Property(e => e.' + var.name + ')')
          codeBuilder.indent
          codeBuilder.add('.HasColumnName("' + XCTETSql::Utils.instance.getStyledVariableName(var) + '")')
          codeBuilder.unindent

          codeBuilder.add
      end
    end
  end
  
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTECSharp::MethodEFConfiguration.new)
