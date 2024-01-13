##
# Class:: Standard
# Author:: Brad Ottoson
#

require 'plugins_core/lang_csharp/utils'
require 'plugins_core/lang_csharp/source_renderer_csharp'
require 'code_elem'
require 'code_elem_parent'
require 'lang_file'
require 'x_c_t_e_plugin'

module XCTECSharp
  class XCTECSharp::TestEngine < XCTEPlugin
    def initialize
      @name = 'test_engine'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.get_styled_class_name(cls.getUName + ' engine')
    end

    def gen_source_files(cls)
      srcFiles = []

      cls.setName(Utils.instance.get_styled_class_name(cls.getUName + ' engine test'))
      if cls.interfacenamespace.hasItems?
        cls.includes << CodeElemInclude.new(cls.interfaceNamespace, cls.getUName + ' interface')
      end

      bld = SourceRendererCSharp.new
      bld.lfName = Utils.instance.get_styled_class_name(cls.name)
      bld.lfExtension = Utils.instance.get_extension('body')

      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      templ = XCTEPlugin.findMethodPlugin('csharp', 'method_test_engine')
      templ.process_dependencies(cls, bld)

      Utils.instance.genFunctionDependencies(cls, bld)
      Utils.instance.genUses(cls.uses, bld)

      Utils.instance.genNamespaceStart(cls.namespace, bld)

      bld.add('[TestClass]')
      classDec = cls.model.visibility + ' class ' + Utils.instance.get_styled_class_name(cls.name)

      bld.start_class(classDec)

      templ.get_definition(cls, bld)

      bld.end_class

      Utils.instance.genNamespaceEnd(cls.namespace, bld)
    end
  end
end

XCTEPlugin.registerPlugin(XCTECSharp::TestEngine.new)
