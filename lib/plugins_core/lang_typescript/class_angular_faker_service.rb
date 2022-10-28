##
# Class:: ClassAngularFakerService
#

require "plugins_core/lang_typescript/class_base.rb"

module XCTETypescript
  class ClassAngularFakerService < ClassBase
    def initialize
      @name = "class_angular_faker_service"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " faker service"
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))
      bld.lfExtension = Utils.instance.getExtension("body")

      cls.addInclude("../../../environments/environment", "environment", "lib")
      cls.addInclude("@angular/core", "Injectable")
      cls.addInclude("@angular/common/http", "HttpClient ")
      cls.addInclude("rxjs", "Observable", "lib")

      fPath = Utils.instance.getStyledFileName(cls.model.name)
      cName = Utils.instance.getStyledClassName(cls.model.name)
      # Eventaully switch to finding standard class and using path from there
      cls.addInclude("shared/interfaces/" + fPath, cName)

      process_dependencies(cls, cfg, bld)
      render_dependencies(cls, cfg, bld)

      bld.separate

      genFileComment(cls, cfg, bld)
      genFileContent(cls, cfg, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileComment(cls, cfg, bld)
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, bld)
      bld.startBlock("@Injectable(")
      bld.add("providedIn: 'root',")
      bld.endBlock(")")
      bld.startClass("export class " + getClassName(cls))

      bld.add("private apiUrl='';")
      # bld.add("private dataExpires: Number = 600; // Seconds")
      # bld.add("private items: " + Utils.instance.getStyledClassName(cls.getUName()) + "[];")

      bld.separate
      bld.startFunction("constructor(private httpClient: HttpClient)")
      bld.add("this.apiUrl = environment.apiUrl;")
      bld.endFunction

      # Generate code for functions
      for fun in cls.functions
        process_function(cls, cfg, bld, fun)
      end

      bld.endClass
    end

    # process variable group
    def process_var_group(cls, cfg, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          bld.add(Utils.instance.getVarDec(var))
        elsif var.elementId == CodeElem::ELEM_COMMENT
          bld.sameLine(Utils.instance.getComment(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          bld.add(var.formatText)
        end
        for group in vGroup.groups
          process_var_group(cls, cfg, bld, group)
        end
      end
    end

    def process_function(cls, cfg, bld, fun)
      bld.separate

      if fun.elementId == CodeElem::ELEM_FUNCTION
        if fun.isTemplate
          templ = XCTEPlugin::findMethodPlugin("typescript", fun.name)
          if templ != nil
            templ.get_definition(cls, cfg, bld)
          else
            #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
          end
        else # Must be empty function
          templ = XCTEPlugin::findMethodPlugin("typescript", "method_empty")
          if templ != nil
            templ.get_definition(fun, cfg)
          else
            #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
          end
        end
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassAngularFakerService.new)
