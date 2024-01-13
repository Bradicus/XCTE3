##
# Class:: Standard
# Author:: Brad Ottoson
#

require 'plugins_core/lang_csharp/utils'
require 'plugins_core/lang_csharp/class_base'
require 'plugins_core/lang_csharp/source_renderer_csharp'
require 'code_elem'
require 'code_elem_use'
require 'code_elem_namespace'
require 'code_elem_parent'
require 'lang_file'
require 'x_c_t_e_plugin'

module XCTECSharp
  class ClassWebApiController < ClassBase
    def initialize
      @name = 'web_api_controller'
      @language = 'csharp'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName + ' controller'
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererCSharp.new
      bld.lfName = Utils.instance.get_styled_file_name(cls.getUName + 'Controller')
      bld.lfExtension = Utils.instance.get_extension('body')
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

      cls.addUse('System.Data.SqlClient')

      Utils.instance.genUses(cls.uses, bld)
      Utils.instance.genNamespaceStart(cls.namespace, bld)

      classDec = cls.model.visibility + ' class ' + getClassName(cls) + 'Controller'

      classDec << ' : ApiController'

      for par in (0..cls.baseClassModelManager.size)
        if !cls.baseClasses[par].nil?
          classDec << ', ' << cls.baseClasses[par].visibility << ' ' << cls.baseClasses[par].name
        end
      end

      bld.start_class(classDec)

      bld.add if cls.functions.length > 0

      # Generate code for functions
      for fun in cls.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin.findMethodPlugin('csharp', fun.name)
            if !templ.nil?
              templ.get_definition(cls, bld, fun)
            else
              puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
            end
          else # Must be empty function
            templ = XCTEPlugin.findMethodPlugin('csharp', 'method_empty')
            if !templ.nil?
              templ.get_definition(cls, bld)
            else
              # puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
            end
          end
        end
      end # class  + cls.getUName()
      bld.end_class

      Utils.instance.genNamespaceEnd(cls.namespace, bld)
    end
  end
end

XCTEPlugin.registerPlugin(XCTECSharp::ClassWebApiController.new)
