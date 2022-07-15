##
# Class:: ClassAngularComponent
#
module XCTETypescript
  class ClassAngularComponent < XCTEPlugin
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
      genFileContent(cls, cfg, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, bld)
      for inc in cls.includes
        bld.add("require '" + inc.path + inc.name + "." + Utils.instance.getExtension("body") + "'")
      end

      bld.add

      filePart = Utils.instance.getStyledFileName(cls.model.name)

      # import { Component, OnInit } from '@angular/core';

      # @Component({
      #   selector: 'app-address-edit',
      #   templateUrl: './address-edit.component.html',
      #   styleUrls: ['./address-edit.component.css']
      # })
      # export class AddressEditComponent implements OnInit {

      #   constructor() { }

      #   ngOnInit(): void {
      #   }

      # }

      bld.add("@Component({")
      bld.indent
      bld.add("selector: 'app-" + filePart + "',")
      bld.add("templateUrl: './" + filePart + ".component.html',")
      bld.add("styleUrls: ['./" + filePart + ".component.css']")
      bld.unindent
      bld.add(")}")

      bld.add

      bld.startBlock("export class " + getClassName(cls) + " implements OnInit ")

      # Generate class variables
      for group in cls.model.groups
        process_var_group(cls, cfg, bld, group)
      end
      bld.add
      bld.add("constructor(private fb: FormBuilder) { }")
      bld.add

      # Generate code for functions
      for fun in cls.functions
        process_function(cls, cfg, bld, fun)
      end

      bld.endBlock
    end

    # process variable group
    def process_var_group(cls, cfg, bld, vGroup)
      clsVar = CodeNameStyling.getStyled(cls.model.name, Utils.instance.langProfile.variableNameStyle)
      bld.add(clsVar + " = this.fb.group({")
      bld.indent

      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          bld.add(Utils.instance.getStyledVariableName(var) + ": [''],")
        end
        for group in vGroup.groups
          process_var_group(cls, cfg, bld, group)
        end
      end

      bld.unindent
      bld.add("});")
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
