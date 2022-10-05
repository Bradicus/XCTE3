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

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      cls.setName(Utils.instance.getStyledClassName(cls.getUName() + " engine test"))
      if cls.interfacenamespace.hasItems?()
        cls.includes << CodeElemInclude.new(cls.interfaceNamespace, cls.getUName() + " interface")
      end

      codeBuilder = SourceRendererCSharp.new
      codeBuilder.lfName = Utils.instance.getStyledClassName(cls.name)
      codeBuilder.lfExtension = Utils.instance.getExtension("body")

      genFileContent(cls, cfg, codeBuilder)

      srcFiles << codeBuilder

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, codeBuilder)
      templ = XCTEPlugin::findMethodPlugin("csharp", "method_test_engine")
      templ.process_dependencies(cls, cfg, codeBuilder)

      Utils.instance.genFunctionDependencies(cls, cfg, codeBuilder)
      Utils.instance.genUses(cls.uses, codeBuilder)

      Utils.instance.genNamespaceStart(cls.namespace, codeBuilder)

      codeBuilder.add("[TestClass]")
      classDec = cls.model.visibility + " class " + Utils.instance.getStyledClassName(cls.name)

      codeBuilder.startClass(classDec)

      templ.get_definition(cls, cfg, codeBuilder)

      codeBuilder.endClass

      Utils.instance.genNamespaceEnd(cls.namespace, codeBuilder)
    end
  end
end

XCTEPlugin::registerPlugin(XCTECSharp::TestEngine.new)
