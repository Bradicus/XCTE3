require "plugins_core/lang_typescript/utils.rb"

##
# Class:: ClassAngularReactiveEdit
#
module XCTEHtml
  class ClassAngularReactiveEdit < ClassBase
    def initialize
      @name = "class_angular_reactive_edit"
      @language = "html"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName()
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererHtml.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls) + ".component")
      bld.lfExtension = Utils.instance.getExtension("body")
      #genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      nested = (cls.xmlElement.attributes["nested"] == "true")
      contentNode = Utils.instance.make_node(cls.genCfg, "div")

      @formName = CodeNameStyling.getStyled(cls.getUName() + " form", Utils.instance.langProfile.variableNameStyle)
      formNode = nil

      if (!nested)
        contentNode.add_child(Utils.instance.make_node(cls.genCfg, "h2").add_text(cls.model.name.capitalize))
        formNode = Utils.instance.make_node(cls.genCfg, "form").
          add_attribute("[formGroup]", @formName).
          add_attribute("(ngSubmit)", "onSubmit()")

        buttonNode = HtmlNode.new("div")

        populateButton = Utils.instance.make_primary_button(cls.genCfg, "Populate").
          add_attribute("(click)", "populateRandom()")

        buttonNode.add_child(populateButton)

        submitButton = Utils.instance.make_primary_button(cls.genCfg, "Save").
          add_attribute("(click)", "onSubmit()")

        buttonNode.add_child(submitButton)

        contentNode.add_child(buttonNode)
      else
        formNode = formNode = Utils.instance.make_node(cls.genCfg, "div").
          add_attribute("[formGroup]", @formName)
      end

      contentNode.add_child(formNode)

      process_var_group(cls, cls.model.varGroup, formNode)

      bld.render_html(contentNode)
    end

    def process_var_group(cls, vGroup, rowContainer)
      rowNode = add_row_node(cls, rowContainer)

      for var in vGroup.vars
        if !var.isList() && (Utils.instance.isPrimitive(var) || var.selectFrom != nil)
          fldNode = make_field(cls, var, nil)
          rowNode.add_child(fldNode)
        else
          if (!var.isList() && var.selectFrom == nil)            
            process_object_var(cls, vGroup, var, rowContainer)
          elsif var.isList()
            process_list_var(cls, vGroup, var, rowContainer)
          end
        end
      end

      for grp in vGroup.varGroups
        process_var_group(cls, grp, rowContainer)
      end
    end

    def process_object_var(cls, vGroup, var, rowContainer)
      vName = Utils.instance.getStyledVariableName(var)
      fieldsetNode = Utils.instance.make_node(cls.genCfg, "fieldset").
        add_attribute("formGroupName", vName)

      rowContainer.add_child(fieldsetNode)

      legNode = Utils.instance.make_node(cls.genCfg, "legend").
        add_text(var.getDisplayName())
      fieldsetNode.add_child(legNode)

      rowNode = add_row_node(cls, rowContainer)
      
      varCls = ClassModelManager.findVarClass(var)

      if varCls != nil
        eachVar(uevParams().wCls(varCls).
          wVarCb(lambda { |innerVar|
          rowNode.add_child(make_field(cls, innerVar, vName))
        }))
      else
        Log.error("Unable to find varible class for var: " + var.name + "  type: " + var.getUType())
      end
    end

    def process_list_var(cls, vGroup, var, rowContainer)
      vName = Utils.instance.getStyledVariableName(var)
      # List of primitive "ids" linked to an options list
      if Utils.instance.isPrimitive(var) && var.selectFrom != nil
        optVar = XCTETypescript::Utils.instance.getOptionsVarFor(var)
        tableNode = TableUtil.instance.make_sel_option_table(var, optVar, vName + "Item", "async")
        rowContainer.add_child(tableNode)
        # Not an options list, just a reglar array of data
      else
        if var.relation != nil
          optVar = XCTETypescript::Utils.instance.getOptionsVarFor(var)
          varCls = ClassModelManager.findVarClass(optVar)
          if (varCls == nil)
            puts "Unable to find variable type called " + var.getUType()
          end

          vName = Utils.instance.getStyledVariableName(optVar)
          rowContainer.add_child(HtmlNode.new("h2").add_text(varCls.model.name.capitalize))
          tableNode = TableUtil.instance.make_table(varCls, vName, vName + "Item", false, "async", true)
          rowContainer.add_child(tableNode)
        else
          varCls = ClassModelManager.findVarClass(var)
          if (varCls == nil)
            puts "Unable to find variable call " + var.getUType()
          end

          rowContainer.add_child(HtmlNode.new("h2").add_text(cls.model.name.capitalize))
          tableNode = TableUtil.instance.make_table(varCls, "item." + vName, vName + "Item", false, "async", true)
          rowContainer.add_child(tableNode)
        end
      end
    end

    def add_row_node(cls, rowContainer)
      rowNode = Utils.instance.make_node(cls.genCfg, "div").
        add_class("row", "form-group")

      rowContainer.add_child(rowNode)

      return rowNode
    end

    def make_field(cls, var, varPrefix)
      varName = Utils.instance.getStyledVariableName(var)
      formVar = CodeNameStyling.getStyled(@formName, Utils.instance.langProfile.variableNameStyle)
      fldNode = HtmlNode.new("div")

      if (cls.genCfg.usesExternalDependency("bootstrap"))
        fldNode.add_class("col-md-3")

        if (var.name.downcase == "id")
          fldNode.add_class("visually-hidden")
        end
      end

      if (varPrefix != nil)
        varId = varPrefix + "-" + varName
      else
        varId = varName
      end

      labelNode = HtmlNode.new("label").add_text(var.getDisplayName())
      inputNode = HtmlNode.new("input")
      selectNode = HtmlNode.new("select")

      if (var.readonly)
        inputNode.add_attribute("[readonly]", "true")
        selectNode.add_attribute("[readonly]", "true")
      end

      fldNode.add_child(labelNode)

      if (cls.genCfg.usesExternalDependency("bootstrap"))
        labelNode.add_class("form-label")
        if (var.getUType().downcase == "boolean")
          inputNode.add_class("form-check-input")
        else
          inputNode.add_class("form-control")
        end
        selectNode.add_class("form-select")   
      end

      labelNode.add_attribute("for", varId)

      if var.selectFrom != nil
        itemName = CodeNameStyling.getStyled(var.selectFrom + " item", Utils.instance.langProfile.variableNameStyle)
        optVarName = CodeNameStyling.getStyled(var.selectFrom + " options", Utils.instance.langProfile.variableNameStyle)
        selectNode.add_attribute("id", varId)
        selectNode.add_attribute("formControlName", Utils.instance.getStyledVariableName(var, ""))
        selectNode.add_child(HtmlNode.new("option").
          add_attribute("*ngFor", "let " + itemName + " of (" + optVarName + " | async)?.data").
          add_attribute("value", itemName + ".id").
          add_text("{{" + itemName + ".name}}"))

        fldNode.add_child(selectNode)
      else
        inputNode.
          add_attribute("id", varId).
          add_attribute("formControlName", varName).
          add_attribute("type", Utils.instance.getInputType(var))
        fldNode.add_child(inputNode)
      end

      # Display validation messages
      if var.needsValidation()
        if varPrefix != nil
          formVarRef = formVar + ".get('" + varPrefix + "')?" + ".get('" + varName + "')"
        else
          formVarRef = formVar + ".get('" + varName + "')"
        end
        validationNode = HtmlNode.new("div").
          add_attribute("*ngIf", formVarRef + "?.invalid && (" + formVarRef + "?.dirty || " + formVarRef + "?.touched)").
          add_class("alert alert-danger")

        if var.required
          validationNode.add_child(HtmlNode.new("div").
            add_attribute("*ngIf", formVarRef + "?.errors?.['required']").
            add_text(var.getDisplayName() + " is required"))
        end

        if var.arrayElemCount > 0
          validationNode.add_child(HtmlNode.new("div").
            add_attribute("*ngIf", formVarRef + "?.errors?.['maxlength']").
            add_text(var.getDisplayName() + " must be " + var.arrayElemCount.to_s() + " characters or less"))
        end

        fldNode.add_child(validationNode)
      end

      return fldNode
    end
  end
end

XCTEPlugin::registerPlugin(XCTEHtml::ClassAngularReactiveEdit.new)
