require 'plugins_core/lang_typescript/class_base'

##
# Class:: ClassAngularModule
#
module XCTETypescript
  class ClassAngularModule < ClassBase
    def initialize
      @name = 'class_angular_module'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName + ' module'
    end

    def getFileName(cls)
      Utils.instance.get_styled_file_name(cls.getUName + '.module')
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = getFileName(cls)
      bld.lfExtension = Utils.instance.get_extension('body')

      fPath = get_styled_file_name(cls.model.name)
      cName = get_styled_class_name(cls.model.name)

      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

      bld.separate

      render_file_comment(cls, bld)
      render_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addInclude('@angular/core', 'NgModule')
      cls.addInclude('@angular/common', 'CommonModule')
      cls.addInclude('@angular/forms', 'ReactiveFormsModule, FormControl, FormGroup, FormArray')
      cls.addInclude('@angular/router', 'RouterModule, Routes')

      if !cls.model.findClassModel('class_angular_module_routing').nil?
        cls.addInclude(get_styled_file_name(cls.getUName) + '/' + get_styled_file_name(cls.getUName + '.routing.module'),
                       get_styled_class_name(cls.getUName + ' routing module'))
      end

      relClasses = Utils.instance.getRelatedClasses(cls)

      for otherCls in relClasses
        if otherCls.plug_name.start_with?('class_angular_reactive_edit') ||
           otherCls.plug_name.start_with?('class_angular_reactive_view') ||
           otherCls.plug_name.start_with?('class_angular_listing')
          plug = XCTEPlugin.findClassPlugin('typescript', otherCls.plug_name)
          cls.addInclude(Utils.instance.get_styled_path_name(otherCls.path) + '/' + plug.getFileName(otherCls),
                         plug.get_class_name(otherCls))
        end
      end

      super

      # Generate class variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wSeparate(true).wVarCb(lambda { |var|
        Utils.instance.try_add_include_for_var(cls, var, 'class_angular_module') if !Utils.instance.is_primitive(var)
      }))
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      relClasses = Utils.instance.getRelatedClasses(cls)

      bld.add('@NgModule({')
      bld.indent
      bld.add 'declarations: ['

      decList = []
      Utils.instance.addClassnamesFor(decList, relClasses, 'typescript', 'class_angular_reactive_edit')
      Utils.instance.addClassnamesFor(decList, relClasses, 'typescript', 'class_angular_reactive_view')
      Utils.instance.addClassnamesFor(decList, relClasses, 'typescript', 'class_angular_listing')

      Utils.instance.renderClassList(decList, bld)

      bld.add '],'

      importList = %w[CommonModule RouterModule]

      for otherCls in relClasses
        if otherCls.plug_name.start_with?('class_angular_reactive_edit') || otherCls.plug_name.start_with?('class_angular_reactive_edit')
          importList.push('ReactiveFormsModule')
        end
      end

      Utils.instance.addClassnamesFor(importList, relClasses, 'typescript', 'class_angular_module_routing')

      process_var_group_imports(cls, bld, cls.model.varGroup, importList)

      bld.add 'imports: ['
      Utils.instance.renderClassList(importList, bld)
      bld.add '],'

      exportList = ['RouterModule']

      Utils.instance.addClassnamesFor(exportList, relClasses, 'typescript', 'class_angular_reactive_edit')
      Utils.instance.addClassnamesFor(exportList, relClasses, 'typescript', 'class_angular_reactive_view')
      Utils.instance.addClassnamesFor(exportList, relClasses, 'typescript', 'class_angular_listing')

      bld.add 'exports:['
      Utils.instance.renderClassList(exportList, bld)
      bld.add '],'

      bld.add 'providers: [],'
      bld.unindent

      bld.add('})')
      bld.start_class('export class ' + get_class_name(cls))

      # Generate code for functions
      for fun in cls.functions
        process_function(cls, bld, fun)
      end

      bld.end_class
    end

    # process variable group
    def process_var_group_imports(_cls, _bld, vGroup, importList)
      for var in vGroup.vars
        if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE && !is_primitive(var)
          varCls = ClassModelManager.findVarClass(var, 'class_angular_reactive_edit')
          if !varCls.nil?
            editClass = varCls.model.findClassModel('class_angular_reactive_edit')
            importList.push(get_styled_class_name(editClass.model.name + ' module')) if !editClass.nil?
          end

          varCls = ClassModelManager.findVarClass(var, 'class_angular_reactive_view')
          if !varCls.nil?
            viewClass = varCls.model.findClassModel('class_angular_reactive_view')
            importList.push(get_styled_class_name(viewClass.model.name + ' module')) if !viewClass.nil?
          end
        end
      end
    end

    def process_function(cls, bld, fun)
      bld.separate

      return unless fun.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION

      if fun.isTemplate
        templ = XCTEPlugin.findMethodPlugin('typescript', fun.name)
        if !templ.nil?
          templ.render_function(cls, bld)
        else
          # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      else # Must be empty function
        templ = XCTEPlugin.findMethodPlugin('typescript', 'method_empty')
        if !templ.nil?
          templ.render_function(fun, cfg)
        else
          # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      end
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassAngularModule.new)
