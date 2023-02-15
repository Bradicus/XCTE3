require "plugins_core/lang_typescript/class_base"

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

    def getUnformattedClassName(cls)
      return cls.getUName() + " routing module"
    end

    def getFileName(cls)
      getStyledFileName(cls.getUName() + ".routing.module")
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererTypescript.new
      bld.lfName = getFileName(cls)
      bld.lfExtension = Utils.instance.getExtension("body")

      fPath = getStyledFileName(cls.model.name)
      cName = getStyledClassName(cls.model.name)

      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

      bld.separate

      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addInclude("@angular/core", "NgModule")
      cls.addInclude("@angular/common", "CommonModule")
      cls.addInclude("@angular/router", "RouterModule, Routes")

      for otherCls in cls.model.classes
        if (otherCls.plugName.start_with?("class_angular_reactive_edit") ||
            otherCls.plugName.start_with?("class_angular_listing"))
          plug = XCTEPlugin::findClassPlugin("typescript", otherCls.plugName)
          cls.addInclude(otherCls.path + "/" + plug.getFileName(otherCls), plug.getClassName(otherCls))
        end
      end

      super
    end

    # Returns the code for the content for this class
    def genFileComment(cls, bld)
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      bld.add("const routes: Routes = [")
      bld.indent
      bld.add("{")
      bld.indent
      bld.add("path: '" + getStyledFileName(cls.getUName()) + "', ")
      bld.add("children: [ ")

      for otherCls in cls.model.classes
        if otherCls.plugName.start_with? "class_angular_reactive_edit"
          viewPath = getStyledFileName("view")
          editPath = getStyledFileName("edit")

          plug = XCTEPlugin::findClassPlugin("typescript", "class_angular_reactive_edit")
          compName = plug.getClassName(otherCls)
          #compName = getClassName(cls)
          bld.iadd("{ path: '" + viewPath + "/:id', component: " + compName + " },")
          bld.iadd("{ path: '" + editPath + "/:id', component: " + compName + ", data: {enableEdit: true} },")
        elsif otherCls.plugName == "class_angular_listing"
          listPath = getStyledFileName("listing")
          plug = XCTEPlugin::findClassPlugin("typescript", "class_angular_listing")
          compName = plug.getClassName(otherCls)
          bld.iadd("{ path: '" + listPath + "', component: " + compName + " },")
        end
      end
      bld.add("]")
      bld.unindent
      bld.add("}")
      bld.unindent
      bld.add("];")

      bld.separate

      bld.add("@NgModule({")

      bld.iadd("imports: [RouterModule.forChild(routes)],")
      bld.iadd("exports: [RouterModule]")

      bld.add("})")
      bld.startClass("export class " + getClassName(cls))

      # Generate code for functions
      for fun in cls.functions
        process_function(cls, bld, fun)
      end

      bld.endClass
    end

    # process variable group
    def process_var_group(cls, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          bld.add(getVarDec(var))
        elsif var.elementId == CodeElem::ELEM_COMMENT
          bld.sameLine(getComment(var))
        elsif var.elementId == CodeElem::ELEM_FORMAT
          bld.add(var.formatText)
        end
        for group in vGroup.varGroups
          process_var_group(cls, bld, group)
        end
      end
    end

    # process variable group
    def process_var_group_imports(cls, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          if !isPrimitive(var)
            varCls = Classes.findVarClass(var)
            editClass = varCls.model.findClassModel("class_angular_reactive_edit")
            if (editClass != nil)
              bld.iadd(getStyledClassName(editClass.model.name + " module") + ",")
            end
          end
        end
      end
    end

    def process_function(cls, bld, fun)
      bld.separate

      if fun.elementId == CodeElem::ELEM_FUNCTION
        if fun.isTemplate
          templ = XCTEPlugin::findMethodPlugin("typescript", fun.name)
          if templ != nil
            templ.get_definition(cls, bld)
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

    def process_var_dependencies(cls, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          if !isPrimitive(var)
            varCls = Classes.findVarClass(var)
            fPath = getStyledFileName(var.getUType() + "")
            cls.addInclude(varCls.path + "/" + fPath + ".module", getStyledClassName(var.getUType() + " module"))
          end
        end
      end

      for grp in vGroup.varGroups
        process_var_dependencies(cls, bld, grp)
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassAngularModuleRouting.new)
