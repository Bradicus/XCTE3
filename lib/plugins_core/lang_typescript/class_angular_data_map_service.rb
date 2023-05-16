require "params/utils_each_var_params.rb"
require "params/utils_each_fun_params.rb"

##
# Class:: ClassAngularReactivePopulateService
#
require "plugins_core/lang_typescript/class_base.rb"
require "plugins_core/lang_typescript/class_base.rb"

module XCTETypescript
  class ClassAngularDatamapService < ClassBase
    def initialize
      @name = "class_angular_data_map_service"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " data map service"
    end

    def getFilePath(cls)
      return cls.path + "/" + Utils.instance.getStyledFileName(getUnformattedClassName(cls))
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))
      bld.lfExtension = Utils.instance.getExtension("body")

      fPath = Utils.instance.getStyledFileName(cls.model.name)
      cName = Utils.instance.getStyledClassName(cls.model.name)
      # Eventaully switch to finding standard class and using path from there
      cls.addInclude("shared/interfaces/" + fPath, cName)

      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

      bld.separate

      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addInclude("@angular/core", "Component, OnInit, Input")
      cls.addInclude("@angular/forms", "ReactiveFormsModule, FormControl, FormGroup, FormArray")
      cls.addInclude("@angular/core", "Injectable")

      # Process variables
      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.isPrimitive(var)
          Utils.instance.tryAddIncludeForVar(cls, var, "ts_interface")

          if !var.hasMultipleItems()
            Utils.instance.tryAddIncludeForVar(cls, var, "class_angular_data_map_service")
          end
        end
      }))

      # Get dependencies for functions
      for funItem in cls.functions
        if funItem.elementId == CodeElem::ELEM_FUNCTION
          if funItem.isTemplate
            templ = XCTEPlugin::findMethodPlugin("typescript", funItem.name)
            if templ != nil
              templ.process_dependencies(cls, bld, funItem)
            else
              # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
            end
          end
        end
      end
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

      constructorParams = Array.new

      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if (!Utils.instance.isPrimitive(var) && !var.hasMultipleItems())
          varCls = ClassPluginManager.findVarClass(var, "class_angular_data_map_service")
          if varCls != nil
            vService = Utils.instance.createVarFor(varCls, "class_angular_data_map_service")
            Utils.instance.addParamIfAvailable(constructorParams, vService)
          end
        end
      }))

      bld.separate
      bld.startBlock("constructor(" + constructorParams.uniq.join(", ") + ")")
      bld.endFunction

      # Generate code for functions
      render_functions(cls, bld)

      bld.endClass
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassAngularDatamapService.new)
