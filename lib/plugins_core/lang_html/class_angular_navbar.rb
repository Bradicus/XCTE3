##
# Class:: ClassAngularNavBar
#
module XCTEHtml
  class ClassAngularNavBar < ClassBase
    def initialize
      @name = "class_angular_navbar"
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
      features = Hash.new
      rootNode = NavigationNode.new("", "/")

      for mdl in ProjectPlanManager.current().models
        for otherCls in mdl.classes
          if (otherCls.plugName.start_with?("class_angular_listing"))
            plug = XCTEPlugin::findClassPlugin("typescript", otherCls.plugName)

            featureName = otherCls.featureGroup
            if featureName == nil
              featureName = otherCls.model.name
            end

            nodeName = featureName

            if otherCls.for != nil
              nodeName = otherCls.for + " " + nodeName
            end

            formattedFeatureName = featureName.capitalize
            curNode = findChildNode(rootNode, formattedFeatureName)

            if curNode == nil
              curNode = NavigationNode.new(formattedFeatureName, nil)
              rootNode.children.push(curNode)
            end

            editPath = plug.get_full_route(otherCls, "listing")
            curNode.children.push(NavigationNode.new(nodeName.capitalize + " listing", editPath))
          elsif otherCls.plugName.start_with?("class_angular_reactive_edit")
            plug = XCTEPlugin::findClassPlugin("typescript", otherCls.plugName)

            featureName = otherCls.featureGroup
            if featureName == nil
              featureName = cls.model.name
            end

            nodeName = featureName

            if otherCls.for != nil
              nodeName = otherCls.for + " " + nodeName
            end

            formattedFeatureName = featureName.capitalize
            curNode = findChildNode(rootNode, formattedFeatureName)

            if curNode == nil
              curNode = NavigationNode.new(formattedFeatureName, nil)
              rootNode.children.push(curNode)
            end

            editPath = plug.get_full_route(otherCls, "edit")
            editPath.push("0")
            curNode.children.push(NavigationNode.new(nodeName.capitalize + " create", editPath))
          end
        end
      end

      bld.startBlock('<nav class="navbar navbar-expand-lg navbar-light bg-light">')
      bld.startBlock('<div class="container-fluid">')

      bld.startBlock '<div class="navbar-collapse" [class.collapse]="collapsed" id="navbarContent">'

      bld.startBlock('<div class="collapse navbar-collapse">')
      bld.startBlock('<ul class="navbar-nav ms-auto">')

      for fNode in rootNode.children
        bld.startBlock '<li class="nav-item" ngbDropdown>'
        bld.add '<a class="nav-link" tabindex="0" ngbDropdownToggle id="navbarDropdown1" role="button"> ' + fNode.name + " </a>"

        bld.startBlock('<div ngbDropdownMenu aria-labelledby="navbarDropdown1" class="dropdown-menu">')
        for cNode in fNode.children
          bld.add '<a ngbDropdownItem routerLink="' + cNode.link.join("/") + '">' + cNode.name + "</a>"
        end
        bld.endBlock "</div>"
        bld.endBlock "</li>"
      end
      #      for group in cls.model.groups
      #        process_var_group_menu(cls, bld, group)
      #      end
      bld.endBlock("</ul>")
      bld.endBlock("</div>")
      bld.endBlock("</div>")
      bld.endBlock("</div>")

      bld.endBlock("</nav>")

      bld.add
    end

    def findChildNode(rootNode, formattedFeatureName)
      if rootNode.children != nil
        for node in rootNode.children
          if node.name == formattedFeatureName
            return node
          end
        end
      end

      return nil
    end

    # process variable group
    def process_var_group_menu(cls, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          varName = Utils.instance.getStyledVariableName(var)

          bld.startBlock('<li class="nav-item">')
          bld.add('<a class="nav-link active" aria-current="page" href="#">' + var.name + "</a>")
          bld.endBlock("</li>")
        end
        for group in vGroup.varGroups
          process_var_group_body(cls, bld, group)
        end
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTEHtml::ClassAngularNavBar.new)
