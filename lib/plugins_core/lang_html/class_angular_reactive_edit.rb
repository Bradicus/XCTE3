require 'plugins_core/lang_typescript/utils'

##
# Class:: ClassAngularReactiveEdit
#
module XCTEHtml
  class ClassAngularReactiveEdit < ClassBase
    def initialize
      @name = 'class_angular_reactive_edit'
      @language = 'html'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name
    end

    def gen_source_files(cls)
      srcFiles = []

      bld = SourceRendererHtml.new
      bld.lfName = Utils.instance.get_styled_file_name(get_unformatted_class_name(cls) + '.component')
      bld.lfExtension = Utils.instance.get_extension('body')
      # render_file_comment(cls, bld)
      render_body_content(cls, bld)

      srcFiles << bld

      srcFiles
    end

    # Returns the code for the content for this class
    def render_body_content(cls, bld)
      nested = (cls.data_node.attributes['nested'] == 'true')
      contentNode = Utils.instance.make_node(cls.gen_cfg, 'div')

      @formName = CodeNameStyling.getStyled(cls.get_u_name + ' form', Utils.instance.langProfile.variableNameStyle)
      formNode = nil

      if !nested
        contentNode.add_child(Utils.instance.make_node(cls.gen_cfg, 'h2').add_text(cls.model.name.capitalize))
        formNode = Utils.instance.make_node(cls.gen_cfg, 'form')
                        .add_attribute('[formGroup]', @formName)
                        .add_attribute('(ngSubmit)', 'onSubmit()')

        buttonNode = HtmlNode.new('div')

        populateButton = Utils.instance.make_primary_button(cls.gen_cfg, 'Populate')
                              .add_attribute('(click)', 'populateRandom()')

        buttonNode.add_child(populateButton)

        submitButton = Utils.instance.make_primary_button(cls.gen_cfg, 'Save')
                            .add_attribute('(click)', 'onSubmit()')

        buttonNode.add_child(submitButton)

        contentNode.add_child(buttonNode)
      else
        formNode = formNode = Utils.instance.make_node(cls.gen_cfg, 'div')
                                   .add_attribute('[formGroup]', @formName)
      end

      contentNode.add_child(formNode)

      process_var_group(cls, cls.model.varGroup, formNode)

      bld.render_html(contentNode)
    end

    def process_var_group(cls, vGroup, rowContainer)
      rowNode = add_row_node(cls, rowContainer)

      for var in vGroup.vars
        if !var.isList && (Utils.instance.is_primitive(var) || !var.selectFrom.nil?)
          fldNode = make_field(cls, var, nil)
          rowNode.add_child(fldNode)
        elsif !var.isList && var.selectFrom.nil?
          process_object_var(cls, vGroup, var, rowNode)
        elsif var.isList
          process_list_var(cls, vGroup, var, rowNode)
        end
      end

      for grp in vGroup.varGroups
        process_var_group(cls, grp, rowNode)
      end
    end

    def process_object_var(cls, _vGroup, var, rowContainer)
      vName = Utils.instance.get_styled_variable_name(var)
      fieldsetNode = Utils.instance.make_node(cls.gen_cfg, 'fieldset')
                          .add_attribute('formGroupName', vName)
                          .add_class('row', 'form-group')

      rowContainer.add_child(fieldsetNode)

      legNode = Utils.instance.make_node(cls.gen_cfg, 'legend')
                     .add_text(var.getdisplay_name)
      fieldsetNode.add_child(legNode)

      rowNode = add_row_node(cls, rowContainer)

      varCls = ClassModelManager.findVarClass(var)

      if !varCls.nil?
        each_var(uevParams.wCls(varCls)
          .wVarCb(lambda { |innerVar|
                    fieldsetNode.add_child(make_field(cls, innerVar, vName))
                  }))
      else
        Log.error('Unable to find varible class for var: ' + var.name + '  type: ' + var.getUType)
      end
    end

    def process_list_var(_cls, _vGroup, var, rowContainer)
      vName = Utils.instance.get_styled_variable_name(var)
      # List of primitive "ids" linked to an options list
      if Utils.instance.is_primitive(var) && !var.selectFrom.nil?
        optVar = XCTETypescript::Utils.instance.getOptionsVarFor(var)
        tableNode = TableUtil.instance.make_sel_option_table(var, optVar, vName + 'Item', 'async')
        rowContainer.add_child(tableNode)
        # Not an options list, just a reglar array of data
      elsif !var.relation.nil?
        optVar = XCTETypescript::Utils.instance.getOptionsVarFor(var)
        varCls = ClassModelManager.findVarClass(optVar)
        puts 'Unable to find variable type called ' + var.getUType if varCls.nil?

        vName = Utils.instance.get_styled_variable_name(optVar)
        rowContainer.add_child(HtmlNode.new('h2').add_text(varCls.model.name.capitalize))
        tableNode = TableUtil.instance.make_table(varCls, vName, vName + 'Item', false, 'async', false)
        rowContainer.add_child(tableNode)
      else
        varCls = ClassModelManager.findVarClass(var)
        puts 'Unable to find variable call ' + var.getUType if varCls.nil?

        rowContainer.add_child(HtmlNode.new('h2').add_text(var.name.capitalize))
        tableNode = TableUtil.instance.make_table(varCls, 'item.' + vName, vName + 'Item', false, '', true)
        rowContainer.add_child(tableNode)
      end
    end

    def add_row_node(cls, rowContainer)
      rowNode = Utils.instance.make_node(cls.gen_cfg, 'div')
                     .add_class('row', 'form-group')

      rowContainer.add_child(rowNode)

      rowNode
    end

    def make_field(cls, var, var_prefix)
      varName = Utils.instance.get_styled_variable_name(var)
      formVar = CodeNameStyling.getStyled(@formName, Utils.instance.langProfile.variableNameStyle)
      fldNode = HtmlNode.new('div')

      if cls.gen_cfg.usesExternalDependency('bootstrap')
        fldNode.add_class('col-md-3')

        fldNode.add_class('visually-hidden') if var.name.downcase == 'id'
      end

      if !var_prefix.nil?
        varId = var_prefix + '-' + varName
      else
        varId = varName
      end

      labelNode = HtmlNode.new('label').add_text(var.getdisplay_name)
      inputNode = HtmlNode.new('input')
      selectNode = HtmlNode.new('select')

      if var.readonly
        inputNode.add_attribute('[readonly]', 'true')
        selectNode.add_attribute('[readonly]', 'true')
      end

      fldNode.add_child(labelNode)

      if cls.gen_cfg.usesExternalDependency('bootstrap')
        labelNode.add_class('form-label')
        if var.getUType.downcase == 'boolean'
          inputNode.add_class('form-check-input')
        else
          inputNode.add_class('form-control')
        end
        selectNode.add_class('form-select')
      end

      labelNode.add_attribute('for', varId)

      if !var.selectFrom.nil?
        itemName = CodeNameStyling.getStyled(var.selectFrom + ' item', Utils.instance.langProfile.variableNameStyle)
        optVarName = CodeNameStyling.getStyled(var.selectFrom + ' options',
                                               Utils.instance.langProfile.variableNameStyle)
        selectNode.add_attribute('id', varId)
        selectNode.add_attribute('formControlName', Utils.instance.get_styled_variable_name(var, ''))
        selectNode.add_child(HtmlNode.new('option')
          .add_attribute('*ngFor', 'let ' + itemName + ' of (' + optVarName + ' | async)?.data')
          .add_attribute('value', '{{' + itemName + '.id}}')
          .add_text('{{' + itemName + '.name}}'))

        fldNode.add_child(selectNode)
      else
        inputNode
          .add_attribute('id', varId)
          .add_attribute('formControlName', varName)
          .add_attribute('type', Utils.instance.getInputType(var))
        fldNode.add_child(inputNode)
      end

      # Display validation messages
      if var.needsValidation
        if !var_prefix.nil?
          formVarRef = formVar + ".get('" + var_prefix + "')?" + ".get('" + varName + "')"
        else
          formVarRef = formVar + ".get('" + varName + "')"
        end
        validationNode = HtmlNode.new('div')
                                 .add_attribute('*ngIf', formVarRef + '?.invalid && (' + formVarRef + '?.dirty || ' + formVarRef + '?.touched)')
                                 .add_class('alert alert-danger')

        if var.required
          validationNode.add_child(HtmlNode.new('div')
            .add_attribute('*ngIf', formVarRef + "?.errors?.['required']")
            .add_text(var.getdisplay_name + ' is required'))
        end

        if var.arrayElemCount > 0
          validationNode.add_child(HtmlNode.new('div')
            .add_attribute('*ngIf', formVarRef + "?.errors?.['maxlength']")
            .add_text(var.getdisplay_name + ' must be ' + var.arrayElemCount.to_s + ' characters or less'))
        end

        fldNode.add_child(validationNode)
      end

      fldNode
    end
  end
end

XCTEPlugin.registerPlugin(XCTEHtml::ClassAngularReactiveEdit.new)
