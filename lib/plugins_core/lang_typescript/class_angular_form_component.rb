require "plugins_core/lang_typescript/class_base.rb"

##
# Class:: ClassAngularComponent
#
module XCTETypescript
  class ClassAngularComponent < ClassBase
    def initialize
      @name = "class_angular_component"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.model.name + " edit component"
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.getStyledFileName(cls.model.name + " edit" + ".component")
      bld.lfExtension = Utils.instance.getExtension("body")
      #genFileComment(cls, cfg, bld)
      get_dependencies(cls, cfg, bld)
      genFileContent(cls, cfg, bld)

      srcFiles << bld

      return srcFiles
    end

    def get_dependencies(cls, codeFun, codeBuilder)
      cls.addInclude("@angular/core", "Component, OnInit")
      cls.addInclude("@angular/forms", "FormControl, FormGroup")
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, bld)
      genImports(cls, cfg, bld)

      bld.add

      filePart = Utils.instance.getStyledFileName(cls.model.name)

      clsVar = CodeNameStyling.getStyled(cls.model.name, Utils.instance.langProfile.variableNameStyle)

      bld.add("@Component({")
      bld.indent
      bld.add("selector: 'app-" + filePart + "',")
      bld.add("templateUrl: './" + filePart + ".component.html',")
      bld.add("styleUrls: ['./" + filePart + ".component.css']")
      bld.unindent
      bld.add(")}")

      bld.add

      bld.startBlock("export class " + getClassName(cls) + " implements OnInit ")
      bld.add("@Input() item = {};")
      bld.add

      # Generate class variables
      for group in cls.model.groups
        process_var_group(cls, cfg, bld, group)
      end

      bld.add
      bld.startBlock("constructor(private fb: FormBuilder, private service: " + Utils.instance.getStyledClassName(cls.model.name) + "Service)")
      bld.endBlock

      bld.add
      bld.startBlock("onInit()")
      bld.add("this." + clsVar + ".setValue(item);")
      bld.endBlock

      bld.add
      bld.startBlock("onSubmit()")
      bld.add("this.service.submit(this." + clsVar + ".value);")
      bld.endBlock

      # Generate code for functions
      for fun in cls.functions
        process_function(cls, cfg, bld, fun)
      end

      bld.endBlock
    end

    # process variable group
    def process_var_group(cls, cfg, bld, vGroup)
      clsVar = CodeNameStyling.getStyled(cls.model.name, Utils.instance.langProfile.variableNameStyle)
      bld.add(clsVar + " = ")

      Utils.instance.getFormgroup(cls, bld, vGroup)
    end

    def process_function(cls, cfg, bld, fun)
      if fun.elementId == CodeElem::ELEM_FUNCTION
        if fun.isTemplate
          templ = XCTEPlugin::findMethodPlugin("typescript", fun.name)
          if templ != nil
            bld.add(templ.get_definition(cls, cfg))
          else
            #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
          end
        else # Must be empty function
          templ = XCTEPlugin::findMethodPlugin("typescript", "method_empty")
          if templ != nil
            bld.add(templ.get_definition(fun, cfg))
          else
            #puts 'ERROR no plugin for function: ' + fun.name + '   language: 'typescript
          end
        end
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassAngularComponent.new)
