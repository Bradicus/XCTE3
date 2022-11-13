##
# Class:: EFConfiguration
# Author:: Brad Ottoson
#

require "plugins_core/lang_csharp/utils.rb"
require "plugins_core/lang_csharp/source_renderer_csharp.rb"
require "code_elem.rb"
require "code_elem_parent.rb"
require "lang_file.rb"
require "x_c_t_e_plugin.rb"

module XCTECSharp
  class ClassEFConfiguration < XCTEPlugin
    def initialize
      @name = "ef_configuration"
      @language = "csharp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(cls.getUName() + " configuration")
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      codeBuilder = SourceRendererCSharp.new
      codeBuilder.lfName = Utils.instance.getStyledFileName(cls.getUName() + " configuration")
      codeBuilder.lfExtension = Utils.instance.getExtension("body")

      process_dependencies(cls, cfg, codeBuilder)

      genFileContent(cls, cfg, codeBuilder)

      srcFiles << codeBuilder

      return srcFiles
    end

    def process_dependencies(cls, cfg, bld)
      cls.addUse("Microsoft.EntityFrameworkCore")
      cls.addUse("Microsoft.EntityFrameworkCore.Metadata.Builders")
      Utils.instance.addClassInclude(cls, "standard")
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, codeBuilder)
      # Add in any dependencies required by functions
      # for fun in cls.functions
      #   if fun.elementId == CodeElem::ELEM_FUNCTION
      #     if fun.isTemplate
      #       templ = XCTEPlugin::findMethodPlugin("csharp", fun.name)
      #       if templ != nil
      #         templ.process_dependencies(cls, fun, cfg, codeBuilder)
      #       else
      #         puts "ERROR no plugin for function: " + fun.name + "   language: csharp"
      #       end
      #     end
      #   end
      # end

      Utils.instance.genUses(cls.uses, codeBuilder)
      Utils.instance.genNamespaceStart(cls.namespace, codeBuilder)

      classDec = cls.model.visibility + " class " + getClassName(cls) + " : IEntityTypeConfiguration<" + Utils.instance.getStyledClassName(cls.getUName()) + ">"

      for par in (0..cls.baseClasses.size)
        if par == 0 && cls.baseClasses[par] != nil
          classDec << " < " << cls.baseClasses[par].visibility << " " << cls.baseClasses[par].name
        elsif cls.baseClasses[par] != nil
          classDec << ", " << cls.baseClasses[par].visibility << " " << cls.baseClasses[par].name
        end
      end

      codeBuilder.startClass(classDec)

      varArray = Array.new
      cls.model.getAllVarsFor(varArray)

      # Generate code for functions
      Utils.instance.genFunctions(cls, codeBuilder)

      codeBuilder.endClass

      Utils.instance.genNamespaceEnd(cls.namespace, codeBuilder)
    end
  end
end

XCTEPlugin::registerPlugin(XCTECSharp::ClassEFConfiguration.new)
