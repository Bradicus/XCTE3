##
# Class:: Standard
# Author:: Brad Ottoson
#

require "plugins_core/lang_csharp/utils.rb"
require "plugins_core/lang_csharp/class_base.rb"
require "plugins_core/lang_csharp/source_renderer_csharp.rb"
require "code_elem.rb"
require "code_elem_use.rb"
require "code_elem_namespace.rb"
require "code_elem_parent.rb"
require "lang_file.rb"
require "x_c_t_e_plugin.rb"

module XCTECSharp
  class ClassWebApiController < ClassBase
    def initialize
      @name = "web_api_controller"
      @language = "csharp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " controller"
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererCSharp.new
      bld.lfName = Utils.instance.getStyledFileName(cls.getUName() + "Controller")
      bld.lfExtension = Utils.instance.getExtension("body")
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)

      # Add in any dependencies required by functions
      for fun in cls.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin::findMethodPlugin("csharp", fun.name)
            if templ != nil
              templ.process_dependencies(cls, bld, fun)
            else
              puts "ERROR no plugin for function: " + fun.name + "   language: csharp"
            end
          end
        end
      end

      cls.addUse("System.Data.SqlClient")

      Utils.instance.genUses(cls.uses, bld)
      Utils.instance.genNamespaceStart(cls.namespace, bld)

      classDec = cls.model.visibility + " class " + getClassName(cls) + "Controller"

      classDec << " : ApiController"

      for par in (0..cls.baseClassModelManager.size)
        if cls.baseClasses[par] != nil
          classDec << ", " << cls.baseClasses[par].visibility << " " << cls.baseClasses[par].name
        end
      end

      bld.startClass(classDec)

      if (cls.functions.length > 0)
        bld.add
      end

      # Generate code for functions
      for fun in cls.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin::findMethodPlugin("csharp", fun.name)
            if templ != nil
              templ.get_definition(cls, bld, fun)
            else
              puts "ERROR no plugin for function: " + fun.name + "   language: csharp"
            end
          else # Must be empty function
            templ = XCTEPlugin::findMethodPlugin("csharp", "method_empty")
            if templ != nil
              templ.get_definition(cls, bld)
            else
              #puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
            end
          end
        end
      end  # class  + cls.getUName()
      bld.endClass

      Utils.instance.genNamespaceEnd(cls.namespace, bld)
    end
  end
end

XCTEPlugin::registerPlugin(XCTECSharp::ClassWebApiController.new)
