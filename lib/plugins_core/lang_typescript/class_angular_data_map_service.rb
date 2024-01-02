require 'params/utils_each_var_params'
require 'params/utils_each_fun_params'

##
# Class:: ClassAngularReactivePopulateService
#
require 'plugins_core/lang_typescript/class_base'
require 'plugins_core/lang_typescript/class_base'

module XCTETypescript
  class ClassAngularDatamapService < ClassBase
    def initialize
      @name = 'class_angular_data_map_service'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName + ' data map service'
    end

    def getFilePath(cls)
      cls.path + '/' + Utils.instance.getStyledFileName(get_unformatted_class_name(cls))
    end

    def genSourceFiles(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.getStyledFileName(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.getExtension('body')

      fPath = Utils.instance.getStyledFileName(cls.model.name)
      cName = Utils.instance.get_styled_class_name(cls.model.name)
      # Eventaully switch to finding standard class and using path from there
      cls.addInclude('shared/dto/model/' + fPath, cName)

      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

      bld.separate

      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addInclude('@angular/core', 'Component, OnInit, Input')
      cls.addInclude('@angular/forms', 'ReactiveFormsModule, FormControl, FormGroup, FormArray')
      cls.addInclude('@angular/core', 'Injectable')

      # Process variables
      Utils.instance.eachVar(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var)
          Utils.instance.tryAddIncludeForVar(cls, var, 'standard')

          Utils.instance.tryAddIncludeForVar(cls, var, 'class_angular_data_map_service') if !var.hasMultipleItems
        end
      }))

      # Get dependencies for functions
      for funItem in cls.functions
        if funItem.elementId == CodeElem::ELEM_FUNCTION && funItem.isTemplate
          templ = XCTEPlugin.findMethodPlugin('typescript', funItem.name)
          if !templ.nil?
            templ.process_dependencies(cls, bld, funItem)
          else
            # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
          end
        end
      end
    end

    # Returns the code for the content for this class
    def genFileComment(cls, bld); end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      bld.startBlock('@Injectable(')
      bld.add("providedIn: 'root',")
      bld.endBlock(')')
      bld.startClass('export class ' + getClassName(cls))

      constructorParams = []

      Utils.instance.eachVar(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var) && !var.hasMultipleItems
          varCls = ClassModelManager.findVarClass(var, 'class_angular_data_map_service')
          if !varCls.nil?
            vService = Utils.instance.createVarFor(varCls, 'class_angular_data_map_service')
            Utils.instance.addParamIfAvailable(constructorParams, vService)
          end
        end
      }))

      bld.separate
      bld.startBlock('constructor(' + constructorParams.uniq.join(', ') + ')')
      bld.endFunction

      # Generate code for functions
      render_functions(cls, bld)

      bld.endClass
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassAngularDatamapService.new)
