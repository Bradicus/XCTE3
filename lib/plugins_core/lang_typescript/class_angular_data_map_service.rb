require "params/utils_each_var_params"
require "params/utils_each_fun_params"

##
# Class:: ClassAngularReactivePopulateService
#
require "plugins_core/lang_typescript/class_base"

module XCTETypescript
  class ClassAngularDatamapService < ClassBase
    def initialize
      @name = "class_angular_data_map_service"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name + " data map service"
    end

    def getFilePath(cls)
      cls.path + "/" + Utils.instance.get_styled_file_name(get_unformatted_class_name(cls))
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.get_styled_file_name(get_unformatted_class_name(cls))
      bld.lfExtension = Utils.instance.get_extension("body")

      fPath = Utils.instance.get_styled_file_name(cls.model.name)
      cName = Utils.instance.get_styled_class_name(cls.model.name)
      # Eventaully switch to finding standard class and using path from there
      cls.addInclude("shared/dto/model/" + fPath, cName)

      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

      bld.separate

      render_file_comment(cls, bld)
      render_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addInclude("@angular/core", "Component, OnInit, Input")
      cls.addInclude("@angular/forms", "ReactiveFormsModule, FormControl, FormGroup, FormArray")
      cls.addInclude("@angular/core", "Injectable")

      # Process variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var)
          Utils.instance.try_add_include_for_var(cls, var, "class_standard")

          Utils.instance.try_add_include_for_var(cls, var, "class_angular_data_map_service") if !var.hasMultipleItems
        end
      }))

      # Get dependencies for functions
      for funItem in cls.functions
        if funItem.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION && funItem.isTemplate
          templ = XCTEPlugin.findMethodPlugin("typescript", funItem.name)
          if !templ.nil?
            templ.process_dependencies(cls, bld, funItem)
          else
            # puts 'ERROR no plugin for function: ' << funItem.name << '   language: cpp'
          end
        end
      end
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      bld.start_block("@Injectable(")
      bld.add("providedIn: 'root',")
      bld.end_block(")")
      bld.start_class("export class " + get_class_name(cls))

      inst_fun = CodeStructure::CodeElemFunction.new(cls)

      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var) && !var.hasMultipleItems
          varCls = ClassModelManager.findVarClass(var, "class_angular_data_map_service")
          if !varCls.nil?
            vService = Utils.instance.create_var_for(varCls, "class_angular_data_map_service", "private")
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

XCTEPlugin.registerPlugin(XCTETypescript::ClassAngularDatamapService.new)
