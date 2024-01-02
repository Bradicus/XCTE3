##
# Class:: ClassAngularDataGenService
#

require 'plugins_core/lang_typescript/class_base'

module XCTETypescript
  class ClassAngularDataGenService < ClassBase
    def initialize
      @name = 'class_angular_data_gen_service'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName + ' data gen service'
    end

    def getFileName(cls)
      Utils.instance.getStyledFileName(get_unformatted_class_name(cls))
    end

    def getFilePath(_cls)
      'shared/services'
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
      cls.addInclude('../../../environments/environment', 'environment', 'lib')
      cls.addInclude('@angular/core', 'Injectable')
      cls.addInclude('rxjs', 'Observable', 'lib')
      cls.addInclude('@faker-js/faker', 'faker')

      # Include variable interfaces
      Utils.instance.eachVar(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var)
          varCls = ClassModelManager.findVarClass(var, 'standard')
          cls.addInclude('shared/dto/model/' + Utils.instance.getStyledFileName(var.getUType),
                         Utils.instance.get_styled_class_name(var.getUType))
        end
      }))

      Utils.instance.eachVar(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var) && !var.hasMultipleItems
          Utils.instance.tryAddIncludeForVar(cls, var, 'class_angular_data_gen_service')
        end
      }))
    end

    # Returns the code for the content for this class
    def genFileComment(cls, bld); end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      bld.startBlock('@Injectable(')
      bld.add("providedIn: 'root',")
      bld.endBlock(')')
      bld.startClass('export class ' + getClassName(cls))

      bld.add('private apiUrl=environment.apiUrl;')
      # bld.add("private dataExpires: Number = 600; // Seconds")
      # bld.add("private items: " + Utils.instance.get_styled_class_name(cls.getUName()) + "[];")

      constructorParams = []

      Utils.instance.eachVar(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var) && !var.hasMultipleItems
          varCls = ClassModelManager.findVarClass(var, 'class_angular_data_gen_service')
          if !varCls.nil?
            vService = Utils.instance.createVarFor(varCls, 'class_angular_data_gen_service')
            Utils.instance.addParamIfAvailable(constructorParams, vService)
          end
        end
      }))

      bld.separate
      bld.startBlock('constructor(' + constructorParams.uniq.join(', ') + ')')
      bld.endFunction

      # Generate code for functions
      for fun in cls.functions
        process_function(cls, bld, fun)
      end

      bld.endClass
    end

    def process_function(cls, bld, fun)
      bld.separate

      return unless fun.elementId == CodeElem::ELEM_FUNCTION

      if fun.isTemplate
        templ = XCTEPlugin.findMethodPlugin('typescript', fun.name)
        if !templ.nil?
          templ.get_definition(cls, bld, fun)
        else
          # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      else # Must be empty function
        templ = XCTEPlugin.findMethodPlugin('typescript', 'method_empty')
        if !templ.nil?
          templ.get_definition(cls, bld, fun)
        else
          # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      end
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassAngularDataGenService.new)
