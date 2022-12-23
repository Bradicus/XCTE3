##
# Class:: Standard
# Author:: Brad Ottoson
#

require "plugins_core/lang_csharp/utils.rb"
require "plugins_core/lang_csharp/source_renderer_csharp.rb"
require "code_elem.rb"
require "code_elem_parent.rb"
require "lang_file.rb"
require "x_c_t_e_plugin.rb"

module XCTECSharp
  class XCTECSharp::TestEngine < XCTEPlugin
    def initialize
      @name = "test_engine"
      @language = "csharp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(cls.getUName() + " engine")
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      cls.setName(Utils.instance.getStyledClassName(cls.getUName() + " engine test"))
      if cls.interfacenamespace.hasItems?()
        cls.includes << CodeElemInclude.new(cls.interfaceNamespace, cls.getUName() + " interface")
      end

      bld = SourceRendererCSharp.new
      bld.lfName = Utils.instance.getStyledClassName(cls.name)
      bld.lfExtension = Utils.instance.getExtension("body")

      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      templ = XCTEPlugin::findMethodPlugin("csharp", "method_test_engine")
      templ.process_dependencies(cls, bld)

      Utils.instance.genFunctionDependencies(cls, bld)
      Utils.instance.genUses(cls.uses, bld)

      Utils.instance.genNamespaceStart(cls.namespace, bld)

      bld.add("[TestClass]")
      classDec = cls.model.visibility + " class " + Utils.instance.getStyledClassName(cls.name)

      bld.startClass(classDec)

      templ.get_definition(cls, bld)

      bld.endClass

      Utils.instance.genNamespaceEnd(cls.namespace, bld)
    end
  end
end

XCTEPlugin::registerPlugin(XCTECSharp::TestEngine.new)
