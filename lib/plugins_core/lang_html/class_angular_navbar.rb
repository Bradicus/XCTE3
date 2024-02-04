##
# Class:: ClassAngularNavBar
#
module XCTEHtml
  class ClassAngularNavBar < ClassBase
    def initialize
      @name = 'class_angular_navbar'
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
      features = {}
      rootNode = NavigationNode.new('', '/')

      for mdl in ProjectPlanManager.current.models
        for otherCls in mdl.classes
          if otherCls.plug_name.start_with?('class_angular_listing')
            plug = XCTEPlugin.findClassPlugin('typescript', otherCls.plug_name)

            featureName = otherCls.feature_group
            featureName = otherCls.model.name if featureName.nil?

            nodeName = featureName

            nodeName = otherCls.variant + ' ' + nodeName if !otherCls.variant.nil?

            formattedFeatureName = featureName.capitalize
            curNode = findChildNode(rootNode, formattedFeatureName)

            if curNode.nil?
              curNode = NavigationNode.new(formattedFeatureName, nil)
              rootNode.children.push(curNode)
            end

            editPath = plug.get_full_route(otherCls, 'listing')
            curNode.children.push(NavigationNode.new(nodeName.capitalize + ' listing', editPath))
          elsif otherCls.plug_name.start_with?('class_angular_reactive_edit')
            plug = XCTEPlugin.findClassPlugin('typescript', otherCls.plug_name)

            featureName = otherCls.feature_group
            featureName = cls.model.name if featureName.nil?

            nodeName = featureName

            nodeName = otherCls.variant + ' ' + nodeName if !otherCls.variant.nil?

            formattedFeatureName = featureName.capitalize
            curNode = findChildNode(rootNode, formattedFeatureName)

            if curNode.nil?
              curNode = NavigationNode.new(formattedFeatureName, nil)
              rootNode.children.push(curNode)
            end

            editPath = plug.get_full_route(otherCls, 'edit')
            editPath += '/0'
            curNode.children.push(NavigationNode.new(nodeName.capitalize + ' create', editPath))
          end
        end
      end

      bld.start_block('<nav class="navbar navbar-expand-lg navbar-light bg-light">')
      bld.start_block('<div class="container-fluid">')

      bld.start_block '<div class="collapse navbar-collapse" id="navbarContent">'
      bld.start_block('<ul class="navbar-nav">')

      for fNode in rootNode.children
        bld.start_block '<li class="nav-item" ngbDropdown>'
        bld.add '<a class="nav-link" tabindex="0" ngbDropdownToggle id="navbarDropdown1" role="button"> ' + fNode.name + ' </a>'

        bld.start_block('<div ngbDropdownMenu aria-labelledby="navbarDropdown1" class="dropdown-menu">')
        for cNode in fNode.children
          bld.add '<a ngbDropdownItem routerLink="' + cNode.link + '">' + cNode.name + '</a>'
        end
        bld.end_block '</div>'
        bld.end_block '</li>'
      end
      #      for group in cls.model.groups
      #        process_var_group_menu(cls, bld, group)
      #      end
      bld.end_block('</ul>')
      bld.end_block('</div>')
      bld.end_block('</div>')

      bld.end_block('</nav>')

      bld.add
    end

    def findChildNode(rootNode, formattedFeatureName)
      if !rootNode.children.nil?
        for node in rootNode.children
          return node if node.name == formattedFeatureName
        end
      end

      nil
    end

    # process variable group
    def process_var_group_menu(cls, bld, vGroup)
      for var in vGroup.vars
        if var.element_id == CodeStructure::CodeElemTypes::ELEM_VARIABLE
          varName = Utils.instance.get_styled_variable_name(var)

          bld.start_block('<li class="nav-item">')
          bld.add('<a class="nav-link active" aria-current="page" href="#">' + var.name + '</a>')
          bld.end_block('</li>')
        end
        for group in vGroup.varGroups
          process_var_group_body(cls, bld, group)
        end
      end
    end
  end
end

XCTEPlugin.registerPlugin(XCTEHtml::ClassAngularNavBar.new)
