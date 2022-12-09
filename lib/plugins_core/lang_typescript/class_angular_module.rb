require "plugins_core/lang_typescript/class_base"

##
# Class:: ClassAngularModule
#
module XCTETypescript
  class ClassAngularModule < ClassBase
    def initialize
      @name = "class_angular_module"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " module"
    end

    def getFileName(cls)
      Utils.instance.getStyledFileName(cls.getUName() + ".module")
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
      cls.addInclude("@angular/forms", "ReactiveFormsModule, FormControl, FormGroup, FormArray")
      cls.addInclude("@angular/router", "RouterModule, Routes")

      if cls.model.findClassModel("class_angular_module_routing") != nil
        cls.addInclude(getStyledFileName(cls.getUName()) + "/" + getStyledFileName(cls.getUName() + ".routing.module"),
                       getStyledClassName(cls.getUName() + " routing module"))
      end

      for otherCls in cls.model.classes
        if (otherCls.ctype.start_with?("class_angular_reactive_edit") ||
            otherCls.ctype.start_with?("class_angular_listing"))
          plug = XCTEPlugin::findClassPlugin("typescript", otherCls.ctype)
          cls.addInclude(otherCls.path + "/" + plug.getFileName(otherCls), plug.getClassName(otherCls))
        end
      end

      super

      # Generate class variables
      Utils.instance.eachVar(UtilsEachVarParams.new(cls, nil, true, lambda { |var|
        if !isPrimitive(var)
          Utils.instance.tryAddIncludeForVar(cls, var, "class_angular_module")
        end
      }))
    end

    # Returns the code for the content for this class
    def genFileComment(cls, bld)
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      # bld.add("const routes: Routes = [")
      # for otherCls in cls.model.classes
      #   if otherCls.ctype.start_with? "class_angular_reactive_edit"
      #     viewPath = getStyledFileName(otherCls.model.name + "/view")
      #     editPath = getStyledFileName(otherCls.model.name + "/edit")

      #     plug = XCTEPlugin::findClassPlugin("typescript", "class_angular_reactive_edit")
      #     compName = plug.getClassName(otherCls)
      #     #compName = getClassName(cls)
      #     bld.iadd("{ path: '" + viewPath + "/:id', component: " + compName + " },")
      #     bld.iadd("{ path: '" + editPath + "/:id', component: " + compName + ", data: {enableEdit: true} },")
      #   elsif otherCls.ctype == "class_angular_listing"
      #     listPath = getStyledFileName(otherCls.model.name + "/listing")
      #     plug = XCTEPlugin::findClassPlugin("typescript", "class_angular_listing")
      #     compName = plug.getClassName(otherCls)
      #     bld.iadd("{ path: '" + listPath + "', component: " + compName + " },")
      #   end
      # end
      # bld.add("];")

      #bld.separate

      bld.add("@NgModule({")
      bld.indent
      bld.add "declarations: ["

      decList = Array.new
      Utils.instance.addClassnamesFor(decList, cls, "typescript", "class_angular_reactive_edit")
      Utils.instance.addClassnamesFor(decList, cls, "typescript", "class_angular_listing")

      Utils.instance.renderClassList(decList, bld)

      bld.add "],"

      importList = ["CommonModule", "RouterModule"]

      for otherCls in cls.model.classes
        if otherCls.ctype.start_with? "class_angular_reactive_edit"
          importList.push("ReactiveFormsModule")
        end
      end

      Utils.instance.addClassnamesFor(importList, cls, "typescript", "class_angular_module_routing")

      for vGroup in cls.model.groups
        process_var_group_imports(cls, bld, vGroup, importList)
      end

      bld.add "imports: ["
      Utils.instance.renderClassList(importList, bld)
      bld.add "],"

      exportList = ["RouterModule"]

      Utils.instance.addClassnamesFor(exportList, cls, "typescript", "class_angular_reactive_edit")
      Utils.instance.addClassnamesFor(exportList, cls, "typescript", "class_angular_listing")

      bld.add "exports:["
      Utils.instance.renderClassList(exportList, bld)
      bld.add "],"

      bld.add "providers: [],"
      bld.unindent

      bld.add("})")
      bld.startClass("export class " + getClassName(cls))

      # Generate code for functions
      for fun in cls.functions
        process_function(cls, bld, fun)
      end

      bld.endClass
    end

    # process variable group
    def process_var_group_imports(cls, bld, vGroup, importList)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          if !isPrimitive(var)
            varCls = Classes.findVarClass(var, "class_angular_reactive_edit")
            editClass = varCls.model.findClassModel("class_angular_reactive_edit")
            if (editClass != nil)
              importList.push(getStyledClassName(editClass.model.name + " module"))
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
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassAngularModule.new)
