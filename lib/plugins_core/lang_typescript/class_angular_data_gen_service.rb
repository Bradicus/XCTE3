##
# Class:: ClassAngularDataGenService
#

require 'plugins_core/lang_typescript/class_base'

module XCTETypescript
  class ClassAngularDataGenService < ClassAngularComponent
    def initialize
      @name = 'class_angular_data_gen_service'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      return cls.getUName + ' data gen service'
    end

    def getFileName(cls)
      return Utils.instance.get_styled_file_name(get_unformatted_class_name(cls))
    end

    def getFilePath(_cls)
      return 'shared/services'
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.get_styled_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.get_extension('body')

      fPath = Utils.instance.get_styled_file_name(cls.model.name)
      cName = Utils.instance.get_styled_class_name(cls.model.name)
      # Eventaully switch to finding standard class and using path from there
      cls.addInclude('shared/dto/model/' + fPath, cName)

      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

      bld.separate

      gen_file_comment(cls, bld)
      gen_body_content(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addInclude('../../../environments/environment', 'environment', 'lib')
      cls.addInclude('@angular/core', 'Injectable')
      cls.addInclude('rxjs', 'Observable', 'lib')
      cls.addInclude('@faker-js/faker', 'faker')

      # Include variable interfaces
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var)
          varCls = ClassModelManager.findVarClass(var, 'standard')
          cls.addInclude('shared/dto/model/' + Utils.instance.get_styled_file_name(var.getUType),
                         Utils.instance.get_styled_class_name(var.getUType))
        end
      }))

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var) && !var.hasMultipleItems
          Utils.instance.try_add_include_for_var(cls, var, 'class_angular_data_gen_service')
        end
      }))
    end

    # Returns the code for the content for this class
    def gen_body_content(cls, bld)
      bld.start_block('@Injectable(')
      bld.add("providedIn: 'root',")
      bld.end_block(')')
      bld.start_class('export class ' + get_class_name(cls))

      bld.add('private apiUrl=environment.apiUrl;')
      # bld.add("private dataExpires: Number = 600; // Seconds")
      # bld.add("private items: " + Utils.instance.get_styled_class_name(cls.getUName()) + "[];")

      constructorParams = []

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var) && !var.hasMultipleItems
          varCls = ClassModelManager.findVarClass(var, 'class_angular_data_gen_service')
          if !varCls.nil?
            vService = Utils.instance.create_var_for(varCls, 'class_angular_data_gen_service')
            Utils.instance.addParamIfAvailable(constructorParams, vService)
          end
        end
      }))

      bld.separate
      bld.start_block('constructor(' + constructorParams.uniq.join(', ') + ')')
      bld.endFunction

      # Generate code for functions
      for fun in cls.functions
        process_function(cls, bld, fun)
      end

      bld.end_class
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
