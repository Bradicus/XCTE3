require 'plugins_core/lang_typescript/class_angular_component'
require 'include_util'

##
# Class:: ClassAngularReactiveView
#
module XCTETypescript
  class ClassAngularReactiveView < ClassAngularComponent
    def initialize
      super

      @name = 'class_angular_reactive_view'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName + ' component'
    end

    def getFileName(cls)
      Utils.instance.get_styled_file_name(cls.getUName + '.component')
    end

    def getFilePath(cls)
      cls.namespace.get('/')
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.get_styled_file_name(cls.getUName + '.component')
      bld.lfExtension = Utils.instance.get_extension('body')
      # render_file_comment(cls, bld)
      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

      render_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addInclude('@angular/core', 'Component, OnInit, Input')
      cls.addInclude('@angular/forms', 'ReactiveFormsModule, FormControl, FormGroup, FormArray, Validators')
      cls.addInclude('@angular/router', 'ActivatedRoute')
      cls.addInclude('rxjs', 'Observable, of', 'lib')

      cls.addInclude('shared/dto/model/' + Utils.instance.get_styled_file_name(cls.model.name),
                     Utils.instance.get_styled_class_name(cls.model.name))

      IncludeUtil.init('class_angular_data_store_service').wModel(cls.model).addTo(cls)
      IncludeUtil.init('class_angular_data_gen_service').wModel(cls.model).addTo(cls)
      IncludeUtil.init('class_angular_data_map_service').wModel(cls.model).addTo(cls)

      each_var(UtilsEachVarParams.new.wCls(cls).wSeparate(true).wVarCb(lambda { |var|
        if !Utils.instance.is_primitive(var)
          cls.addInclude('shared/dto/model/' + Utils.instance.get_styled_file_name(var.getUType),
                         Utils.instance.get_styled_class_name(var.getUType))
        end
        if !var.selectFrom.nil?
          optVar = Utils.instance.getOptionsVarFor(var)
          cls.addInclude('shared/dto/model/' + Utils.instance.get_styled_file_name(optVar.getUType),
                         Utils.instance.get_styled_class_name(optVar.getUType))

          bCls = ClassModelManager.findClass(cls.model.name, 'standard')
          optStoreVar = Utils.instance.create_var_for(bCls, 'class_angular_data_store_service')
          Utils.instance.try_add_include_for_var(bCls, optVar, 'class_angular_data_store_service')
          Utils.instance.try_add_include_for_var(cls, optVar, 'class_angular_data_store_service')
        end
      }))

      cls.addInclude('shared/paging/filtered-page-resp-tpl', 'FilteredPageRespTpl')
      cls.addInclude('shared/paging/filtered-page-req-tpl', 'FilteredPageReqTpl')

      super
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      bld.add

      selectorName = Utils.instance.get_styled_file_name(cls.getUName)
      filePart = Utils.instance.get_styled_file_name(cls.getUName)

      clsVar = CodeNameStyling.getStyled(cls.getUName + ' form', Utils.instance.langProfile.variableNameStyle)
      storeServiceVar = Utils.instance.create_var_for(cls, 'class_angular_data_store_service')
      dataGenServiceVar = Utils.instance.create_var_for(cls, 'class_angular_data_gen_service')
      userPopulateServiceVar = Utils.instance.create_var_for(cls, 'class_angular_data_map_service')

      bld.add('@Component({')
      bld.indent
      bld.add("selector: 'app-" + selectorName + "',")
      bld.add("templateUrl: './" + filePart + ".component.html',")
      bld.add("styleUrls: ['./" + filePart + ".component.css']")
      bld.unindent
      bld.add('})')

      bld.add

      bld.start_block('export class ' + get_class_name(cls) + ' implements OnInit ')
      bld.add('public item: ' + Utils.instance.get_styled_class_name(cls.model.name) + ' = new ' + Utils.instance.get_styled_class_name(cls.model.name) + '();')
      bld.separate

      # Generate class variables
      process_var_group(cls, bld, cls.model.varGroup)

      # Generate any selection list variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.selectFrom.nil?
          optVar = Utils.instance.getOptionsVarFor(var)
          bld.add(Utils.instance.get_var_dec(optVar))
          reqVar = Utils.instance.getOptionsReqVarFor(var)
          bld.add(Utils.instance.get_var_dec(reqVar))
        end
      }))

      bld.separate

      constructorParams = []
      Utils.instance.addParamIfAvailable(constructorParams, storeServiceVar)
      Utils.instance.addParamIfAvailable(constructorParams, dataGenServiceVar)
      Utils.instance.addParamIfAvailable(constructorParams, userPopulateServiceVar)

      # Generate any selection list variable parameters for data stores
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.selectFrom.nil?
          optVar = Utils.instance.getOptionsVarFor(var)
          optCls = ClassModelManager.findClass(var.selectFrom, 'standard')
          if optVar.nil?
            Log.error('No options var for var: ' + var.name)
          elsif optCls.nil?
            Log.error('No ts_interface class for var: ' + var.name)
          else
            dataStoreOptServiceVar = Utils.instance.create_var_for(optCls, 'class_angular_data_store_service')
            if !dataStoreOptServiceVar.nil?
              Utils.instance.addParamIfAvailable(constructorParams, dataStoreOptServiceVar)
            else
              Log.error("couldn't find data store service for: " + var.name)
            end
          end
        end
      }))

      constructorParams.push('private route: ActivatedRoute')

      bld.start_function_paramed('constructor', constructorParams)
      bld.end_block

      bld.separate
      bld.start_block('ngOnInit()')
      bld.add('this.route.paramMap.subscribe(params => {')
      bld.indent
      bld.add("let idVal = params.get('id');")
      idVar = cls.model.getFilteredVars(->(var) { var.name == 'id' })
      if Utils.instance.is_numeric?(idVar[0])
        bld.add('this.item.id = idVal !== null ? parseInt(idVal) : 0;')
      else
        bld.add("this.item.id = idVal !== null ? idVal : '';")
      end

      bld.separate

      bld.start_block('if (!this.item?.id)')

      bld.add('this.item = new ' + Utils.instance.get_styled_class_name(cls.model.name) + ';')
      # bld.add("this." + Utils.instance.get_styled_variable_name(dataGenServiceVar) + ".initData(this.item);")
      bld.mid_block 'else'
      bld.start_block 'this.' + Utils.instance.get_styled_variable_name(storeServiceVar) + '.detail(this.item.id).subscribe(data => {'
      bld.add 'this.item = data;'
      bld.add 'this.populate();'
      bld.end_block '});'
      bld.end_block
      bld.unindent
      bld.add('});')

      # Load any selection lists needed
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if !var.selectFrom.nil?
          optVar = Utils.instance.getOptionsVarFor(var)
          reqVar = Utils.instance.getOptionsReqVarFor(var)
          optCls = ClassModelManager.findClass(var.selectFrom, 'standard')
          if optVar.nil?
            Log.error('No options var for var: ' + var.name)
          elsif optCls.nil?
            Log.error('No ts_interface class for var: ' + var.name)
          else
            dataStoreOptServiceVar = Utils.instance.create_var_for(optCls, 'class_angular_data_store_service')
            if !dataStoreOptServiceVar.nil?
              bld.add('this.' + Utils.instance.get_styled_variable_name(optVar) + ' = this.' +
                      Utils.instance.get_styled_variable_name(dataStoreOptServiceVar) + '.listing(this.' + Utils.instance.get_styled_variable_name(reqVar) + ');')
            else
              Log.error('No class_angular_data_store_service variable for class: ' + var.name)
            end
          end
        end
      }))

      bld.separate
      bld.add('this.populate();')
      bld.end_block

      render_functions(cls, bld)

      bld.end_block
    end

    # process variable group
    def process_var_group(cls, bld, vGroup)
      clsVar = CodeNameStyling.getStyled(cls.getUName + ' form', Utils.instance.langProfile.variableNameStyle)
      bld.add(clsVar + ' = ')

      Utils.instance.renderReactiveFormGroup(cls, bld, vGroup, true)
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassAngularReactiveView.new)
