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
  class ClassTsqlDataStore < XCTEPlugin
    def initialize
      @name = "tsql_data_store"
      @language = "csharp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(cls.getUName() + " data store")
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " data store"
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      cls.setName(getClassName(cls))

      if cls.interfaceNamespace.hasItems?()
        cls.addUse(cls.interfaceNamespace.get("."), "I" + getUnformattedClassName(cls))
        Utils.instance.addClassInclude(cls, "standard")
      end

      codeBuilder = SourceRendererCSharp.new
      codeBuilder.lfName = cls.name
      codeBuilder.lfExtension = Utils.instance.getExtension("body")
      genFileContent(cls, cfg, codeBuilder)

      srcFiles << codeBuilder

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, codeBuilder)
      Utils.instance.genFunctionDependencies(cls, cfg, codeBuilder)
      Utils.instance.genUses(cls.uses, codeBuilder)
      Utils.instance.genNamespaceStart(cls.namespace, codeBuilder)

      classDec = cls.model.visibility + " class " + cls.name

      inheritsFrom = Array.new

      for baseClass in cls.baseClasses
        inheritsFrom << baseClass.name
      end
      if cls.interfaceNamespace.hasItems?()
        inheritsFrom << Utils.instance.getStyledClassName("i " + getUnformattedClassName(cls))
      end

      for par in (0..inheritsFrom.size)
        if par == 0 && inheritsFrom[par] != nil
          classDec << " : " << inheritsFrom[par]
        elsif inheritsFrom[par] != nil
          classDec << ", " << inheritsFrom[par]
        end
      end

      codeBuilder.startClass(classDec)

      Utils.instance.genFunctions(cls, codeBuilder)

      codeBuilder.endClass

      Utils.instance.genNamespaceEnd(cls.namespace, codeBuilder)
    end
  end
end

XCTEPlugin::registerPlugin(XCTECSharp::ClassTsqlDataStore.new)
