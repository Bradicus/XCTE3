require 'plugins_core/lang_typescript/class_base'

##
# Class:: ClassAngularModule
#
module XCTETypescript
  class ClassAngularModuleRouting < ClassBase
    def initialize
      @name = 'class_angular_module_routing'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName + ' routing module'
    end

    def getFileName(cls)
      get_styled_file_name(cls.getUName + '.routing.module')
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
      gen_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addInclude('@angular/core', 'NgModule')
      cls.addInclude('@angular/common', 'CommonModule')
      cls.addInclude('@angular/router', 'RouterModule, Routes')

      if !cls.model.featureGroup.nil?
        fClasses = ClassModelManager.findFeatureClasses(cls.model.featureGroup)

        for otherCls in fClasses
          if otherCls.plugName.start_with?('class_angular_reactive_edit') ||
             otherCls.plugName.start_with?('class_angular_reactive_view') ||
             otherCls.plugName.start_with?('class_angular_listing')
            plug = XCTEPlugin.findClassPlugin('typescript', otherCls.plugName)
            cls.addInclude(Utils.instance.get_styled_path_name(otherCls.path) + '/' + plug.getFileName(otherCls),
                           plug.get_class_name(otherCls))
          end
        end
      end

      for otherCls in cls.model.classes
        if otherCls.plugName.start_with?('class_angular_reactive_edit') ||
           otherCls.plugName.start_with?('class_angular_reactive_view') ||
           otherCls.plugName.start_with?('class_angular_listing')
          plug = XCTEPlugin.findClassPlugin('typescript', otherCls.plugName)
          cls.addInclude(Utils.instance.get_styled_path_name(otherCls.path) + '/' + plug.getFileName(otherCls),
                         plug.get_class_name(otherCls))
        end
      end

      super
    end

    # Returns the code for the content for this class
    def gen_body_content(cls, bld)
      bld.add('const routes: Routes = [')
      bld.indent
      bld.add('{')
      bld.indent
      bld.add("path: '" + get_styled_file_name(cls.getUName) + "', ")
      bld.add('children: [ ')

      pathLines = []

      if !cls.model.featureGroup.nil?
        fClasses = ClassModelManager.findFeatureClasses(cls.model.featureGroup)

        for otherCls in fClasses
          addPathsForClass(cls, bld, otherCls, pathLines)
        end
      end

      for otherCls in cls.model.classes
        addPathsForClass(cls, bld, otherCls, pathLines)
      end

      uniqLines = pathLines.uniq

      for pline in uniqLines
        bld.iadd pline
      end

      bld.add(']')
      bld.unindent
      bld.add('}')
      bld.unindent
      bld.add('];')

      bld.separate

      bld.add('@NgModule({')

      bld.iadd('imports: [RouterModule.forChild(routes)],')
      bld.iadd('exports: [RouterModule]')

      bld.add('})')
      bld.start_class('export class ' + get_class_name(cls))

      # Generate code for functions
      for fun in cls.functions
        process_function(cls, bld, fun)
      end

      bld.end_class
    end

    def addPathsForClass(_cls, _bld, otherCls, pathLines)
      if otherCls.plugName.start_with? 'class_angular_reactive_edit'
        plug = XCTEPlugin.findClassPlugin('typescript', 'class_angular_reactive_edit')
        editPath = plug.get_relative_route(otherCls, 'edit')

        compName = plug.get_class_name(otherCls)
        # compName = get_class_name(cls)
        pathLines.push("{ path: '" + editPath.join('/') + "/:id', component: " + compName + ' },')
      elsif otherCls.plugName.start_with? 'class_angular_reactive_view'
        plug = XCTEPlugin.findClassPlugin('typescript', 'class_angular_reactive_view')
        viewPath = plug.get_relative_route(otherCls, 'view')

        compName = plug.get_class_name(otherCls)
        # compName = get_class_name(cls)
        pathLines.push("{ path: '" + viewPath.join('/') + "/:id', component: " + compName + ' },')
      elsif otherCls.plugName == 'class_angular_listing'
        plug = XCTEPlugin.findClassPlugin('typescript', 'class_angular_listing')

        listPath = plug.get_relative_route(otherCls, 'listing')
        compName = plug.get_class_name(otherCls)
        pathLines.push("{ path: '" + listPath.join('/') + "', component: " + compName + ' },')
      end
    end

    # process variable group
    def process_var_group(cls, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          bld.add(getVarDec(var))
        elsif var.elementId == CodeElem::ELEM_COMMENT
          bld.same_line(getComment(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          bld.add(var.formatText)
        end
        for group in vGroup.varGroups
          process_var_group(cls, bld, group)
        end
      end
    end

    # process variable group
    def process_var_group_imports(_cls, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE && !is_primitive(var)
          varCls = ClassModelManager.findVarClass(var)
          editClass = varCls.model.findClassModel('class_angular_reactive_edit')
          bld.iadd(get_styled_class_name(editClass.model.name + ' module') + ',') if !editClass.nil?
        end
      end
    end

    def process_function(cls, bld, fun)
      bld.separate

      return unless fun.elementId == CodeElem::ELEM_FUNCTION

      if fun.isTemplate
        templ = XCTEPlugin.findMethodPlugin('typescript', fun.name)
        if !templ.nil?
          templ.get_definition(cls, bld)
        else
          # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      else # Must be empty function
        templ = XCTEPlugin.findMethodPlugin('typescript', 'method_empty')
        if !templ.nil?
          templ.get_definition(fun, cfg)
        else
          # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      end
    end

    def process_var_dependencies(cls, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE && !is_primitive(var)
          varCls = ClassModelManager.findVarClass(var)
          fPath = get_styled_file_name(var.getUType + '')
          cls.addInclude(varCls.path + '/' + fPath + '.module', get_styled_class_name(var.getUType + ' module'))
        end
      end

      for grp in vGroup.varGroups
        process_var_dependencies(cls, bld, grp)
      end
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassAngularModuleRouting.new)
