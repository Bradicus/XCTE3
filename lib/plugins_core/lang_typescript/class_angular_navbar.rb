##
# Class:: ClassAngularNavbar
#
require "active_component"
require "navigation_node"
require "managers/project_plan_manager"

module XCTETypescript
  class ClassAngularNavbar < ClassBase
    def initialize
      @name = "class_angular_navbar"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " component"
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.getStyledFileName(cls.getUName() + ".component")
      bld.lfExtension = Utils.instance.getExtension("body")

      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def process_dependencies(cls, bld)
      cls.addInclude("@angular/core", "Component")
    end

    # Returns the code for the comment for this class
    def genFileComment(cls, bld)
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      filePart = Utils.instance.getStyledFileName(cls.getUName())

      bld.startClass("class NavNode")
      bld.add("name: string;")
      bld.add("url: string | null;")
      bld.add("children: NavNode[] = [];")

      bld.startFunction("constructor(name: string, url: string | null)")

      bld.add("this.name = name;")
      bld.add("this.url = url;")
      bld.endFunction
      bld.endBlock
      bld.separate

      bld.add("@Component({")
      bld.indent
      bld.add("selector: 'app-" + filePart + "',")
      bld.add("templateUrl: './" + filePart + ".component.html',")
      bld.add("styleUrls: ['./" + filePart + ".component.css']")
      bld.unindent
      bld.add("})")

      bld.startClass("export class " + getClassName(cls))

      bld.add('public navNode:NavNode = new NavNode("", null);')
      bld.add "collapsed = true;"
      bld.separate

      bld.startFunction("constructor()")

      features = Hash.new
      rootNode = NavigationNode.new("", "/")

      for mdl in ProjectPlanManager.current().models
        for otherCls in mdl.classes
          if (otherCls.plugName.start_with?("class_angular_listing"))
            plug = XCTEPlugin::findClassPlugin("typescript", otherCls.plugName)

            featureName = otherCls.featureGroup
            if featureName == nil
              featureName = cls.model.name
            end

            formattedFeatureName = featureName.capitalize
            curNode = findChildNode(rootNode, formattedFeatureName)

            if curNode == nil
              curNode = NavigationNode.new(formattedFeatureName, nil)
              rootNode.children.push(curNode)
            end

            editPath = plug.get_full_route(otherCls, "listing")
            curNode.children.push(NavigationNode.new(formattedFeatureName + " listing", editPath))
          elsif otherCls.plugName.start_with?("class_angular_reactive_edit")
            plug = XCTEPlugin::findClassPlugin("typescript", otherCls.plugName)

            featureName = otherCls.featureGroup
            if featureName == nil
              featureName = cls.model.name
            end

            formattedFeatureName = featureName.capitalize
            curNode = findChildNode(rootNode, formattedFeatureName)

            if curNode == nil
              curNode = NavigationNode.new(formattedFeatureName, nil)
              rootNode.children.push(curNode)
            end

            editPath = plug.get_full_route(otherCls, "edit")
            curNode.children.push(NavigationNode.new(featureName.capitalize + " create", editPath))
          end
        end
      end

      bld.add "var newNode: NavNode;"
      bld.add "var cNode: NavNode;"

      for nd in rootNode.children
        renderAddNodeLine(bld, nd, "newNode", "this.navNode")

        for cnd in nd.children
          renderAddNodeLine(bld, cnd, "cNode", "newNode")
        end
      end

      bld.endFunction

      bld.separate

      bld.startFunction "addNode(toNode: NavNode, name: string, link: string | null)"
      bld.add "var newNode = new NavNode(name, link);"
      bld.add "toNode.children.push(newNode);"
      bld.add "return newNode;"
      bld.endFunction

      bld.endClass
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

    def renderAddNodeLine(bld, nd, assignTo, addToNode)
      if nd.link != nil
        bld.add(assignTo + " = this.addNode(" + addToNode + ', "' + nd.name + '", "' + nd.link.join("/") + '");')
      else
        bld.add(assignTo + " = this.addNode(" + addToNode + ', "' + nd.name + '", null);')
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassAngularNavbar.new)
