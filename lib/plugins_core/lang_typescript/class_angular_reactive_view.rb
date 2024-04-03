require "plugins_core/lang_typescript/class_angular_component"
require "include_util"

##
# Class:: ClassAngularReactiveView
#
module XCTETypescript
  class ClassAngularReactiveView < ClassAngularComponent
    def initialize
      super

      @name = "class_angular_reactive_view"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name + " component"
    end

    def get_file_name(cls)
      Utils.instance.style_as_file_name(cls.get_u_name + ".component")
    end

    def getFilePath(cls)
      cls.namespace.get("/")
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.style_as_file_name(cls.get_u_name + ".component")
      bld.lfExtension = Utils.instance.get_extension("body")
      # render_file_comment(cls, bld)
      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

      render_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addInclude("@angular/core", "Component, OnInit, Input")
      cls.addInclude("@angular/forms", "ReactiveFormsModule, FormControl, FormGroup, FormArray, Validators")
      cls.addInclude("@angular/router", "ActivatedRoute")
      cls.addInclude("rxjs", "Observable, of", "lib")

      cls.addInclude("shared/dto/model/" + Utils.instance.style_as_file_name(cls.model.name),
                     Utils.instance.style_as_class(cls.model.name))

      IncludeUtil.init("class_angular_data_store_service").wModel(cls.model).addTo(cls)
      IncludeUtil.init("class_angular_data_gen_service").wModel(cls.model).addTo(cls)
      IncludeUtil.init("class_angular_data_map_service").wModel(cls.model).addTo(cls)

      each_var(UtilsEachVarParams.new.wCls(cls).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var)
          cls.addInclude("shared/dto/model/" + Utils.instance.style_as_file_name(var.getUType),
                         Utils.instance.style_as_class(var.getUType))
        end
        if !var.selectFrom.nil?
          optVar = Utils.instance.get_options_var_for(var)
          cls.addInclude("shared/dto/model/" + Utils.instance.style_as_file_name(optVar.getUType),
                         Utils.instance.style_as_class(optVar.getUType))

          bCls = ClassModelManager.findClass(cls.model.name, "class_standard")
          optStoreVar = Utils.instance.create_var_for(bCls, "class_angular_data_store_service")
          Utils.instance.try_add_include_for_var(bCls, optVar, "class_angular_data_store_service")
          Utils.instance.try_add_include_for_var(cls, optVar, "class_angular_data_store_service")
        end
      }))

      cls.addInclude("shared/paging/filtered-page-resp-tpl", "FilteredPageRespTpl")
      cls.addInclude("shared/paging/filtered-page-req-tpl", "FilteredPageReqTpl")

      super
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      bld.add

      selectorName = Utils.instance.style_as_file_name(cls.get_u_name)
      filePart = Utils.instance.style_as_file_name(cls.get_u_name)

      clsVar = CodeNameStyling.getStyled(cls.get_u_name + " form", Utils.instance.langProfile.variableNameStyle)
      storeServiceVar = Utils.instance.create_var_for(cls, "class_angular_data_store_service", "private")
      dataGenServiceVar = Utils.instance.create_var_for(cls, "class_angular_data_gen_service", "private")
      populateServiceVar = Utils.instance.create_var_for(cls, "class_angular_data_map_service", "private")

      bld.render_component_declaration(ComponentConfig.new
        .w_selector_name(selectorName)
        .w_file_part(filePart)
        .w_imports(["CommonModule, ReactiveFormsModule"]))

      bld.add

      bld.start_block("export class " + get_class_name(cls) + " implements OnInit ")
      bld.add("public item: " + Utils.instance.style_as_class(cls.model.name) + " = new " + Utils.instance.style_as_class(cls.model.name) + "();")
      bld.separate

      # Generate class variables
      process_var_group(cls, bld, cls.model.varGroup)

      # Generate any selection list variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.selectFrom.nil?
          optVar = Utils.instance.get_options_var_for(var)
          bld.add(Utils.instance.get_var_dec(optVar))
          reqVar = Utils.instance.get_options_req_var_for(var)
          bld.add(Utils.instance.get_var_dec(reqVar))
        end
      }))

      bld.separate

      inst_fun = CodeStructure::CodeElemFunction.new(cls)

      inst_fun.add_param(storeServiceVar)
      inst_fun.add_param(dataGenServiceVar)
      inst_fun.add_param(populateServiceVar)

      # Generate any selection list variable parameters for data stores
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.selectFrom.nil?
          optVar = Utils.instance.get_options_var_for(var)
          optCls = ClassModelManager.findClass(var.selectFrom, "class_standard")
          if optVar.nil?
            Log.error("No options var for var: " + var.name)
          elsif optCls.nil?
            Log.error("No ts_interface class for var: " + var.name)
          else
            dataStoreOptServiceVar = Utils.instance.create_var_for(optCls, "class_angular_data_store_service", "private")

            if !dataStoreOptServiceVar.nil?
              inst_fun.add_param(dataStoreOptServiceVar)
            else
              Log.error("couldn't find data store service for: " + var.name)
            end
          end
        end
      }))

      inst_fun.add_param_from("route", "ActivatedRoute", "private")

      bld.start_function("constructor", inst_fun)
      bld.end_block

      bld.separate
      bld.start_block("ngOnInit()")
      bld.add("this.route.paramMap.subscribe(params => {")
      bld.indent
      bld.add("let idVal = params.get('id');")
      idVar = cls.model.getFilteredVars(->(var) { var.name == "id" })
      if Utils.instance.is_numeric?(idVar[0])
        bld.add("this.item.id = idVal !== null ? parseInt(idVal) : 0;")
      else
        bld.add("this.item.id = idVal !== null ? idVal : '';")
      end

      bld.separate

      bld.start_block("if (!this.item?.id)")

      bld.add("this.item = new " + Utils.instance.style_as_class(cls.model.name) + ";")
      # bld.add("this." + Utils.instance.get_styled_variable_name(dataGenServiceVar) + ".initData(this.item);")
      bld.mid_block "else"
      bld.start_block "this." + Utils.instance.get_styled_variable_name(storeServiceVar) + ".detail(this.item.id).subscribe(data => {"
      bld.add "this.item = data;"
      bld.add "this.populate();"
      bld.end_block "});"
      bld.end_block
      bld.unindent
      bld.add("});")

      # Load any selection lists needed
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.selectFrom.nil?
          optVar = Utils.instance.get_options_var_for(var)
          reqVar = Utils.instance.get_options_req_var_for(var)
          optCls = ClassModelManager.findClass(var.selectFrom, "class_standard")
          if optVar.nil?
            Log.error("No options var for var: " + var.name)
          elsif optCls.nil?
            Log.error("No ts_interface class for var: " + var.name)
          else
            dataStoreOptServiceVar = Utils.instance.create_var_for(optCls, "class_angular_data_store_service")
            if !dataStoreOptServiceVar.nil?
              bld.add("this." + Utils.instance.get_styled_variable_name(optVar) + " = this." +
                      Utils.instance.get_styled_variable_name(dataStoreOptServiceVar) + ".listing(this." + Utils.instance.get_styled_variable_name(reqVar) + ");")
            else
              Log.error("No class_angular_data_store_service variable for class: " + var.name)
            end
          end
        end
      }))

      bld.separate
      bld.add("this.populate();")
      bld.end_block

      render_functions(cls, bld)

      bld.end_block
    end

    # process variable group
    def process_var_group(cls, bld, vGroup)
      clsVar = CodeNameStyling.getStyled(cls.get_u_name + " form", Utils.instance.langProfile.variableNameStyle)
      bld.add(clsVar + " = ")

      Utils.instance.render_reactive_form_group(cls, bld, vGroup, true)
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassAngularReactiveView.new)
