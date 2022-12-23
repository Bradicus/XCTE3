##
# Class:: Standard
# Author:: Brad Ottoson
#

require "plugins_core/lang_csharp/utils.rb"
require "plugins_core/lang_csharp/class_base.rb"
require "plugins_core/lang_csharp/source_renderer_csharp.rb"
require "code_elem.rb"
require "code_elem_parent.rb"
require "lang_file.rb"
require "x_c_t_e_plugin.rb"

module XCTECSharp
  class ClassTsqlDataStore < ClassBase
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

    def genSourceFiles(cls)
      srcFiles = Array.new

      cls.setName(getClassName(cls))

      if cls.interfaceNamespace.hasItems?()
        cls.addUse(cls.interfaceNamespace.get("."), "I" + getUnformattedClassName(cls))
        Utils.instance.addClassInclude(cls, "standard")
      end

      bld = SourceRendererCSharp.new
      bld.lfName = cls.name
      bld.lfExtension = Utils.instance.getExtension("body")
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      Utils.instance.genFunctionDependencies(cls, bld)
      Utils.instance.genUses(cls.uses, bld)
      Utils.instance.genNamespaceStart(cls.namespace, bld)

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

      bld.startClass(classDec)

      render_functions(cls, bld)

      bld.endClass

      Utils.instance.genNamespaceEnd(cls.namespace, bld)
    end
  end
end

XCTEPlugin::registerPlugin(XCTECSharp::ClassTsqlDataStore.new)
