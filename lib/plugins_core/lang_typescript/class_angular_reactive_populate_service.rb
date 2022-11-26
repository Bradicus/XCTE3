require "utils_each_var_params.rb"
require "utils_each_fun_params.rb"

##
# Class:: ClassAngularReactivePopulateService
#
require "plugins_core/lang_typescript/class_base.rb"
require "plugins_core/lang_typescript/class_base.rb"

module XCTETypescript
  class ClassAngularReactivePopulateService < ClassBase
    def initialize
      @name = "class_angular_reactive_populate_service"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " form populate service"
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))
      bld.lfExtension = Utils.instance.getExtension("body")

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

    def process_dependencies(cls, cfg, bld)
      cls.addInclude("@angular/core", "Component, OnInit, Input")
      cls.addInclude("@angular/forms", "ReactiveFormsModule, FormControl, FormGroup, FormArray")

      # Process variables
      Utils.instance.eachVar(UtilsEachVarParams.new(cls, bld, true, lambda { |var|
        if !Utils.instance.isPrimitive(var)
          varCls = Classes.findVarClass(var)
          cls.addInclude("shared/interfaces/" + Utils.instance.getStyledFileName(var.getUType()), Utils.instance.getStyledClassName(var.getUType()))
        end
      }))
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
      bld.startFunction("constructor()")
      bld.endFunction

      # Generate code for functions
      Utils.instance.eachFun(UtilsEachFunParams.new(cls, bld, lambda { |fun|
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
      }))

      bld.endClass
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassAngularReactivePopulateService.new)
