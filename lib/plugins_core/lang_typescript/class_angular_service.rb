##
# Class:: ClassAngularService
#
module XCTETypescript
  class ClassAngularService < XCTEPlugin
    def initialize
      @name = "class_angular_service"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.model.name
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      bld = SourceRendererRuby.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))
      bld.lfExtension = Utils.instance.getExtension("body")
      genRubyFileComment(cls, cfg, bld)
      genRubyFileContent(cls, cfg, bld)

      srcFiles << rubyFile

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, bld)
      for inc in cls.includes
        bld.add("import '" + inc.path + inc.name + "." + Utils.instance.getExtension("body") + "'")
      end

      if !cls.includes.empty?
        bld.add
      end

      if cls.hasAnArray
        bld.add  # If we declaired array size variables add a seperator
      end

      # Generate class variables
      bld.add("    # -- Variables --")
      for group in vGroup.groups
        process_var_group(cls, cfg, bld, group)
      end
      bld.add
      # Generate code for functions
      for fun in cls.functionSection
        process_function(cls, cfg, bld, fun)
      end
    end

    # process variable group
    def process_var_group(cls, cfg, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          bld.add("    " + Utils.instance.getVarDec(var))
        elsif var.elementId == CodeElem::ELEM_COMMENT
          bld.sameLine("    " + Utils.instance.getComment(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          bld.add(var.formatText)
        end
        for group in vGroup.groups
          process_var_group(cls, cfg, bld, group)
        end
      end
    end

    def process_function(cls, cfg, bld, fun)
      if fun.elementId == CodeElem::ELEM_FUNCTION
        if fun.isTemplate
          templ = XCTEPlugin::findMethodPlugin("typescript", fun.name)
          if templ != nil
            bld.add(templ.get_definition(cls, cfg))
          else
            #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
          end
        else # Must be empty function
          templ = XCTEPlugin::findMethodPlugin("typescript", "method_empty")
          if templ != nil
            bld.add(templ.get_definition(fun, cfg))
          else
            #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
          end
        end
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassAngularService.new)
