##
# Class:: ClassAngularDataGenService
#

require "plugins_core/lang_typescript/class_base"

module XCTETypescript
  class ClassAngularDataGenService < ClassAngularComponent
    def initialize
      @name = "class_angular_data_gen_service"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      return cls.get_u_name + " data gen service"
    end

    def get_file_name(cls)
      return Utils.instance.style_as_file_name(get_unformatted_class_name(cls))
    end

    def getFilePath(_cls)
      return "shared/services"
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.style_as_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.get_extension("body")

      fPath = Utils.instance.style_as_file_name(cls.model.name)
      cName = Utils.instance.style_as_class(cls.model.name)
      # Eventaully switch to finding standard class and using path from there
      cls.addInclude("shared/dto/model/" + fPath, cName)

      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

      bld.separate

      render_file_comment(cls, bld)
      render_body_content(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def process_dependencies(cls, bld)
      include_env_file(cls)

      cls.addInclude("@angular/core", "Injectable")
      cls.addInclude("rxjs", "Observable", "lib")
      cls.addInclude("@faker-js/faker", "faker")

      # Include variable interfaces
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var)
          varCls = ClassModelManager.findVarClass(var, "class_standard")
          Utils.instance.try_add_include_for(cls, varCls, "class_standard")
        end
      }))

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var) && !var.hasMultipleItems
          Utils.instance.try_add_include_for_var(cls, var, "class_angular_data_gen_service")
        end
      }))
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      bld.start_block("@Injectable(")
      bld.add("providedIn: 'root',")
      bld.end_block(")")
      bld.start_class("export class " + get_class_name(cls))

      bld.add("private apiUrl=environment.apiUrl;")
      # bld.add("private dataExpires: Number = 600; // Seconds")
      # bld.add("private items: " + Utils.instance.style_as_class(cls.get_u_name()) + "[];")

      inst_fun = CodeStructure::CodeElemFunction.new(cls)

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var) && !var.hasMultipleItems
          varCls = ClassModelManager.findVarClass(var, "class_angular_data_gen_service")
          if !varCls.nil?
            vService = Utils.instance.create_var_for(varCls, "class_angular_data_gen_service", "private")
            inst_fun.add_unique_param(vService)
          end
        end
      }))

      bld.separate
      bld.start_function("constructor", inst_fun)
      bld.endFunction

      # Generate code for functions
      render_functions(cls, bld)

      bld.end_class
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassAngularDataGenService.new)
