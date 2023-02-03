##
# Class:: ClassAngularDataGenService
#

require "plugins_core/lang_typescript/class_base.rb"

module XCTETypescript
  class ClassAngularDataGenService < ClassBase
    def initialize
      @name = "class_angular_data_gen_service"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " data gen service"
    end

    def getFileName(cls)
      Utils.instance.getStyledFileName(getUnformattedClassName(cls))
    end

    def getFilePath(cls)
      return "shared/services"
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      editClass = DerivedClassGenerator.getEditClassRepresentation(cls)

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(editClass))
      bld.lfExtension = Utils.instance.getExtension("body")

      fPath = Utils.instance.getStyledFileName(editClass.model.name)
      cName = Utils.instance.getStyledClassName(editClass.model.name)
      # Eventaully switch to finding standard class and using path from there
      editClass.addInclude("shared/interfaces/" + fPath, cName)

      process_dependencies(editClass, bld)
      render_dependencies(editClass, bld)

      bld.separate

      genFileComment(editClass, bld)
      genFileContent(editClass, bld)

      srcFiles << bld

      return srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addInclude("../../../environments/environment", "environment", "lib")
      cls.addInclude("@angular/core", "Injectable")
      cls.addInclude("@angular/common/http", "HttpClient ")
      cls.addInclude("rxjs", "Observable", "lib")
      cls.addInclude("@faker-js/faker", "faker")

      # Include variable interfaces
      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.isPrimitive(var)
          varCls = Classes.findVarClass(var, "ts_interface")
          cls.addInclude("shared/interfaces/" + Utils.instance.getStyledFileName(var.getUType()), Utils.instance.getStyledClassName(var.getUType()))
        end
      }))

      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if (!Utils.instance.isPrimitive(var) && !var.hasMultipleItems())
          Utils.instance.tryAddIncludeForVar(cls, var, "class_angular_data_gen_service")
        end
      }))
    end

    # Returns the code for the content for this class
    def genFileComment(cls, bld)
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      bld.startBlock("@Injectable(")
      bld.add("providedIn: 'root',")
      bld.endBlock(")")
      bld.startClass("export class " + getClassName(cls))

      bld.add("private apiUrl=environment.apiUrl;")
      # bld.add("private dataExpires: Number = 600; // Seconds")
      # bld.add("private items: " + Utils.instance.getStyledClassName(cls.getUName()) + "[];")

      constructorParams = Array.new

      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if (!Utils.instance.isPrimitive(var) && !var.hasMultipleItems())
          varCls = Classes.findVarClass(var, "class_angular_data_gen_service")
          if varCls != nil
            vService = Utils.instance.createVarFor(varCls, "class_angular_data_gen_service")
            Utils.instance.addParamIfAvailable(constructorParams, vService)
          end
        end
      }))

      bld.separate
      bld.startBlock("constructor(" + constructorParams.uniq.join(", ") + ")")
      bld.endFunction

      # Generate code for functions
      for fun in cls.functions
        process_function(cls, bld, fun)
      end

      bld.endClass
    end

    def process_function(cls, bld, fun)
      bld.separate

      if fun.elementId == CodeElem::ELEM_FUNCTION
        if fun.isTemplate
          templ = XCTEPlugin::findMethodPlugin("typescript", fun.name)
          if templ != nil
            templ.get_definition(cls, bld)
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

XCTEPlugin::registerPlugin(XCTETypescript::ClassAngularDataGenService.new)
