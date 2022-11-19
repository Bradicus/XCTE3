##
# Class:: Interface
# Author:: Brad Ottoson
#

require "plugins_core/lang_csharp/utils.rb"
require "plugins_core/lang_csharp/source_renderer_csharp.rb"
require "code_elem.rb"
require "code_elem_parent.rb"
require "lang_file.rb"
require "x_c_t_e_plugin.rb"

module XCTECSharp
  class ClassInterface < XCTEPlugin
    def initialize
      @name = "interface"
      @language = "csharp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      if (cls.parentElem.is_a?(CodeStructure::CodeElemClassGen))
        parentPlug = XCTEPlugin::findClassPlugin(@language, cls.parentElem.ctype)
        return "i " + parentPlug.getUnformattedClassName(cls.parentElem)
      else
        return "i " + cls.getUName()
      end
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      if (cls.parentElem.is_a?(CodeStructure::CodeElemClassGen))
        parentPlug = XCTEPlugin::findClassPlugin(@language, cls.parentElem.ctype)
        cls.setName("i " + parentPlug.getUnformattedClassName(cls.parentElem))
      else
        cls.setName("i " + cls.getUName())
      end

      cls.addUse("System.Data.SqlClient", "SqlConnection")

      bld = SourceRendererCSharp.new
      bld.lfName = Utils.instance.getStyledClassName(cls.name)
      bld.lfExtension = Utils.instance.getExtension("body")
      genFileContent(cls, cfg, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, bld)

      # Add in any dependencies required by functions
      for fun in cls.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin::findMethodPlugin("csharp", fun.name)
            if templ != nil
              templ.process_dependencies(cls, fun, cfg, bld)
            else
              puts "ERROR no plugin for function: " + fun.name + "   language: csharp"
            end
          end
        end
      end

      Utils.instance.genUses(cls.uses, bld)

      # Process namespace items
      if cls.namespace.hasItems?()
        bld.startBlock("namespace " << cls.namespace.get("."))
      end

      classDec = cls.model.visibility + " interface " + Utils.instance.getStyledClassName(cls.name)

      for par in (0..cls.baseClasses.size)
        if par == 0 && cls.baseClasses[par] != nil
          classDec << " : " << cls.baseClasses[par].visibility << " " << cls.baseClasses[par].name
        elsif cls.baseClasses[par] != nil
          classDec << ", " << cls.baseClasses[par].visibility << " " << cls.baseClasses[par].name
        end
      end

      bld.startClass(classDec)

      # Generate code for functions
      for fun in cls.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin::findMethodPlugin("csharp", fun.name)
            if templ != nil
              templ.get_declairation(cls, fun, cfg, bld)
            else
              #puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
            end
          else # Must be empty function
            templ = XCTEPlugin::findMethodPlugin("csharp", "method_empty")
            if templ != nil
              templ.get_declairation(fun, cfg)
            else
              #puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
            end
          end
        end
      end  # class  + cls.getUName()
      bld.endClass

      # Process namespace items
      if cls.namespace.hasItems?()
        bld.endBlock(" // namespace " + cls.namespace.get("."))
        bld.add
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTECSharp::ClassInterface.new)
