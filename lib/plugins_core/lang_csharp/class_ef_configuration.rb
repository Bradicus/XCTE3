##
# Class:: EFConfiguration
# Author:: Brad Ottoson
#

require 'plugins_core/lang_csharp/utils'
require 'plugins_core/lang_csharp/class_base'
require 'plugins_core/lang_csharp/source_renderer_csharp'
require 'code_elem'
require 'code_elem_parent'
require 'lang_file'
require 'x_c_t_e_plugin'

module XCTECSharp
  class ClassEFConfiguration < ClassBase
    def initialize
      @name = 'ef_configuration'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.get_styled_class_name(cls.getUName + ' configuration')
    end

    def genSourceFiles(cls)
      srcFiles = []

      bld = SourceRendererCSharp.new
      bld.lfName = Utils.instance.getStyledFileName(cls.getUName + ' configuration')
      bld.lfExtension = Utils.instance.getExtension('body')

      process_dependencies(cls, bld)

      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def process_dependencies(cls, _bld)
      cls.addUse('Microsoft.EntityFrameworkCore')
      cls.addUse('Microsoft.EntityFrameworkCore.Metadata.Builders')
      Utils.instance.addClassInclude(cls, 'standard')
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      # Add in any dependencies required by functions
      # for fun in cls.functions
      #   if fun.elementId == CodeElem::ELEM_FUNCTION
      #     if fun.isTemplate
      #       templ = XCTEPlugin::findMethodPlugin("csharp", fun.name)
      #       if templ != nil
      #         templ.process_dependencies(cls, bld, fun)
      #       else
      #         puts "ERROR no plugin for function: " + fun.name + "   language: csharp"
      #       end
      #     end
      #   end
      # end

      Utils.instance.genUses(cls.uses, bld)
      Utils.instance.genNamespaceStart(cls.namespace, bld)

      classDec = cls.model.visibility + ' class ' + getClassName(cls) + ' : IEntityTypeConfiguration<' + Utils.instance.get_styled_class_name(cls.getUName) + '>'

      for par in (0..cls.baseClassModelManager.size)
        if par == 0 && !cls.baseClasses[par].nil?
          classDec << ' < ' << cls.baseClasses[par].visibility << ' ' << cls.baseClasses[par].name
        elsif !cls.baseClasses[par].nil?
          classDec << ', ' << cls.baseClasses[par].visibility << ' ' << cls.baseClasses[par].name
        end
      end

      bld.startClass(classDec)

      # Generate code for functions
      render_functions(cls, bld)

      bld.endClass

      Utils.instance.genNamespaceEnd(cls.namespace, bld)
    end
  end
end

XCTEPlugin.registerPlugin(XCTECSharp::ClassEFConfiguration.new)
