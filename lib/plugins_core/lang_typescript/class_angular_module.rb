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

    def get_unformatted_class_name(cls)
      cls.get_u_name + " module"
    end

    def get_file_name(cls)
      Utils.instance.style_as_file_name(cls.get_u_name + ".module")
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererTypescript.new
      bld.lfName = get_file_name(cls)
      bld.lfExtension = Utils.instance.get_extension("body")

      fPath = style_as_file_name(cls.model.name)
      cName = style_as_class(cls.model.name)

      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

      bld.separate

      render_file_comment(cls, bld)
      render_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addInclude("@angular/core", "NgModule")
      cls.addInclude("@angular/common", "CommonModule")
      cls.addInclude("@angular/forms", "ReactiveFormsModule, FormControl, FormGroup, FormArray")
      cls.addInclude("@angular/router", "RouterModule, Routes")

      if !cls.model.findClassModel("class_angular_module_routing").nil?
        cls.addInclude(style_as_file_name(cls.get_u_name) + "/" + style_as_file_name(cls.get_u_name + ".routing.module"),
                       style_as_class(cls.get_u_name + " routing module"))
      end

      relClasses = Utils.instance.get_related_classes(cls)

      for otherCls in relClasses
        if otherCls.plug_name.start_with?("class_angular_reactive_edit") ||
           otherCls.plug_name.start_with?("class_angular_reactive_view") ||
           otherCls.plug_name.start_with?("class_angular_listing")
          plug = XCTEPlugin.findClassPlugin("typescript", otherCls.plug_name)
          cls.addInclude(Utils.instance.style_as_path_name(otherCls.path) + "/" + plug.get_file_name(otherCls),
                         plug.get_class_name(otherCls))
        end
      end

      super

      # Generate class variables
      Utils.instance.each_var(UtilsEachVarParams.new.wCls(cls).wSeparate(true).wVarCb(lambda { |var|
        Utils.instance.try_add_include_for_var(cls, var, "class_angular_module") if !Utils.instance.is_primitive(var)
      }))
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      relClasses = Utils.instance.get_related_classes(cls)

      bld.add("@NgModule({")
      bld.indent
      bld.add "declarations: ["

      decList = []
      Utils.instance.add_class_names_for(decList, relClasses, "typescript", "class_angular_reactive_edit")
      Utils.instance.add_class_names_for(decList, relClasses, "typescript", "class_angular_reactive_view")
      Utils.instance.add_class_names_for(decList, relClasses, "typescript", "class_angular_listing")

      Utils.instance.render_class_list(decList, bld)

      bld.add "],"

      importList = %w[CommonModule RouterModule]

      for otherCls in relClasses
        if otherCls.plug_name.start_with?("class_angular_reactive_edit") || otherCls.plug_name.start_with?("class_angular_reactive_edit")
          importList.push("ReactiveFormsModule")
        end
      end

      Utils.instance.add_class_names_for(importList, relClasses, "typescript", "class_angular_module_routing")

      process_var_group_imports(cls, bld, cls.model.varGroup, importList)

      bld.add "imports: ["
      Utils.instance.render_class_list(importList, bld)
      bld.add "],"

      exportList = ["RouterModule"]

      Utils.instance.add_class_names_for(exportList, relClasses, "typescript", "class_angular_reactive_edit")
      Utils.instance.add_class_names_for(exportList, relClasses, "typescript", "class_angular_reactive_view")
      Utils.instance.add_class_names_for(exportList, relClasses, "typescript", "class_angular_listing")

      bld.add "exports:["
      Utils.instance.render_class_list(exportList, bld)
      bld.add "],"

      bld.add "providers: [],"
      bld.unindent

      bld.add("})")
      bld.start_class("export class " + get_class_name(cls))

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
          varCls = ClassModelManager.findVarClass(var, "class_angular_reactive_edit")
          if !varCls.nil?
            editClass = varCls.model.findClassModel("class_angular_reactive_edit")
            importList.push(style_as_class(editClass.model.name + " module")) if !editClass.nil?
          end

          varCls = ClassModelManager.findVarClass(var, "class_angular_reactive_view")
          if !varCls.nil?
            viewClass = varCls.model.findClassModel("class_angular_reactive_view")
            importList.push(style_as_class(viewClass.model.name + " module")) if !viewClass.nil?
          end
        end
      end
    end

    def process_function(cls, bld, fun)
      bld.separate

      return unless fun.element_id == CodeStructure::CodeElemTypes::ELEM_FUNCTION

      if fun.isTemplate
        templ = XCTEPlugin.findMethodPlugin("typescript", fun.name)
        if !templ.nil?
          templ.render_function(cls, bld)
        else
          # puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
        end
      else # Must be empty function
        templ = XCTEPlugin.findMethodPlugin("typescript", "method_empty")
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
