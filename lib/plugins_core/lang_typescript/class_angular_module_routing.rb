##
# Class:: ClassAngularModule
#
module XCTETypescript
  class ClassAngularModuleRouting < ClassBase
    def initialize
      @name = "class_angular_module_routing"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " routing module"
    end

    def getFileName(cls)
      getStyledFileName(cls.getUName() + ".routing.module")
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      bld = SourceRendererTypescript.new
      bld.lfName = getFileName(cls)
      bld.lfExtension = Utils.instance.getExtension("body")

      fPath = getStyledFileName(cls.model.name)
      cName = getStyledClassName(cls.model.name)

      process_dependencies(cls, cfg, bld)
      render_dependencies(cls, cfg, bld)

      bld.separate

      genFileComment(cls, cfg, bld)
      genFileContent(cls, cfg, bld)

      srcFiles << bld

      return srcFiles
    end

    def process_dependencies(cls, cfg, bld)
      cls.addInclude("@angular/core", "NgModule")
      cls.addInclude("@angular/common", "CommonModule")
      cls.addInclude("@angular/router", "Routes, RouterModule, ActivatedRoute")

      for otherCls in cls.model.classes
        if (otherCls.ctype.start_with?("class_angular_reactive_edit") ||
            otherCls.ctype.start_with?("class_angular_listing"))
          plug = XCTEPlugin::findClassPlugin("typescript", otherCls.ctype)
          cls.addInclude(otherCls.path + "/" + plug.getFileName(otherCls), plug.getClassName(otherCls))
        end
      end

      super
    end

    # Returns the code for the content for this class
    def genFileComment(cls, cfg, bld)
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, bld)
      bld.add("const routes: Routes = [")
      for otherCls in cls.model.classes
        if otherCls.ctype.start_with? "class_angular_reactive_edit"
          viewPath = getStyledFileName("view")
          editPath = getStyledFileName("edit")

          plug = XCTEPlugin::findClassPlugin("typescript", "class_angular_reactive_edit")
          compName = plug.getClassName(otherCls)
          #compName = getClassName(cls)
          bld.iadd("{ path: '" + viewPath + "/:id', component: " + compName + " },")
          bld.iadd("{ path: '" + editPath + "/:id', component: " + compName + ", data: {enableEdit: true} },")
        elsif otherCls.ctype == "class_angular_listing"
          listPath = getStyledFileName("listing")
          plug = XCTEPlugin::findClassPlugin("typescript", "class_angular_listing")
          compName = plug.getClassName(otherCls)
          bld.iadd("{ path: '" + listPath + "', component: " + compName + " },")
        end
      end
      bld.add("];")

      bld.separate

      bld.add("@NgModule({")

      bld.iadd("imports: [RouterModule.forChild(routes)],")
      bld.iadd("exports: [RouterModule]")

      bld.add("})")
      bld.startClass("export class " + getClassName(cls))

      # Generate code for functions
      for fun in cls.functions
        process_function(cls, cfg, bld, fun)
      end

      bld.endClass
    end

    # process variable group
    def process_var_group(cls, cfg, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          bld.add(getVarDec(var))
        elsif var.elementId == CodeElem::ELEM_COMMENT
          bld.sameLine(getComment(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          bld.add(var.formatText)
        end
        for group in vGroup.groups
          process_var_group(cls, cfg, bld, group)
        end
      end
    end

    # process variable group
    def process_var_group_imports(cls, cfg, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          if !isPrimitive(var)
            varCls = Classes.findVarClass(var)
            editClass = varCls.model.findClass("class_angular_reactive_edit")
            if (editClass != nil)
              bld.iadd(getStyledClassName(editClass.model.name + " module") + ",")
            end
          end
        end
      end
    end

    def process_function(cls, cfg, bld, fun)
      bld.separate

      if fun.elementId == CodeElem::ELEM_FUNCTION
        if fun.isTemplate
          templ = XCTEPlugin::findMethodPlugin("typescript", fun.name)
          if templ != nil
            templ.get_definition(cls, cfg, bld)
          else
            #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
          end
        else # Must be empty function
          templ = XCTEPlugin::findMethodPlugin("typescript", "method_empty")
          if templ != nil
            templ.get_definition(fun, cfg)
          else
            #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
          end
        end
      end
    end

    def process_var_dependencies(cls, cfg, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          if !isPrimitive(var)
            varCls = Classes.findVarClass(var)
            fPath = getStyledFileName(var.getUType() + "")
            cls.addInclude(varCls.path + "/" + fPath + ".module", getStyledClassName(var.getUType() + " module"))
          end
        end
      end

      for grp in vGroup.groups
        process_var_dependencies(cls, cfg, bld, grp)
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassAngularModuleRouting.new)
