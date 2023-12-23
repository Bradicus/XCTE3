##
# Class:: Interface
# Author:: Brad Ottoson
#

require 'plugins_core/lang_csharp/utils'
require 'plugins_core/lang_csharp/source_renderer_csharp'
require 'code_elem'
require 'code_elem_parent'
require 'lang_file'
require 'x_c_t_e_plugin'

module XCTECSharp
  class ClassInterface < XCTEPlugin
    def initialize
      @name = 'interface'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return 'i ' + cls.getUName unless cls.parentElem.is_a?(CodeStructure::CodeElemClassGen)

      parentPlug = XCTEPlugin.findClassPlugin(@language, cls.parentElem.plugName)
      'i ' + parentPlug.get_unformatted_class_name(cls.parentElem)
    end

    def genSourceFiles(cls)
      srcFiles = []

      if cls.parentElem.is_a?(CodeStructure::CodeElemClassGen)
        parentPlug = XCTEPlugin.findClassPlugin(@language, cls.parentElem.plugName)
        cls.setName('i ' + parentPlug.get_unformatted_class_name(cls.parentElem))
      else
        cls.setName('i ' + cls.getUName)
      end

      cls.addUse('System.Data.SqlClient', 'SqlConnection')

      bld = SourceRendererCSharp.new
      bld.lfName = Utils.instance.get_styled_class_name(cls.name)
      bld.lfExtension = Utils.instance.getExtension('body')
      genFileContent(cls, bld)

      srcFiles << bld

      srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      # Add in any dependencies required by functions
      for fun in cls.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION && fun.isTemplate
          templ = XCTEPlugin.findMethodPlugin('csharp', fun.name)
          if !templ.nil?
            templ.process_dependencies(cls, bld, fun)
          else
            puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
          end
        end
      end

      Utils.instance.genUses(cls.uses, bld)

      # Process namespace items
      bld.startBlock('namespace ' << cls.namespace.get('.')) if cls.namespace.hasItems?

      classDec = cls.model.visibility + ' interface ' + Utils.instance.get_styled_class_name(cls.name)

      for par in (0..cls.baseClassModelManager.size)
        if par == 0 && !cls.baseClasses[par].nil?
          classDec << ' : ' << cls.baseClasses[par].visibility << ' ' << cls.baseClasses[par].name
        elsif !cls.baseClasses[par].nil?
          classDec << ', ' << cls.baseClasses[par].visibility << ' ' << cls.baseClasses[par].name
        end
      end

      bld.startClass(classDec)

      bld.endClass

      # Process namespace items
      return unless cls.namespace.hasItems?

      bld.endBlock(' // namespace ' + cls.namespace.get('.'))
      bld.add
    end
  end
end

XCTEPlugin.registerPlugin(XCTECSharp::ClassInterface.new)
