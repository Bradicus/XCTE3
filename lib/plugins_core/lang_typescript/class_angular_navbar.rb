##
# Class:: ClassAngularNavbar
#
require 'active_component'
require 'navigation_node'

require 'managers/project_plan_manager'
require 'plugins_core/lang_typescript/class_angular_component'

module XCTETypescript
  class ClassAngularNavbar < ClassAngularComponent
    def initialize
      super
      
      @name = 'class_angular_navbar'
      @language = 'typescript'
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.getUName + ' component'
    end

    def process_dependencies(cls, _bld)
      cls.addInclude('@angular/core', 'Component')
    end

    # Returns the code for the content for this class
    def gen_body_content(cls, bld)
      filePart = Utils.instance.get_styled_file_name(cls.getUName)

      bld.start_class('class NavNode')
      bld.add('name: string;')
      bld.add('url: string | null;')
      bld.add('children: NavNode[] = [];')

      bld.start_function('constructor(name: string, url: string | null)')

      bld.add('this.name = name;')
      bld.add('this.url = url;')
      bld.endFunction
      bld.end_block
      bld.separate

      bld.add('@Component({')
      bld.indent
      bld.add("selector: 'app-" + filePart + "',")
      bld.add("templateUrl: './" + filePart + ".component.html',")
      bld.add("styleUrls: ['./" + filePart + ".component.css']")
      bld.unindent
      bld.add('})')

      bld.start_class('export class ' + get_class_name(cls))

      bld.add('public navNode:NavNode = new NavNode("", null);')
      bld.add 'collapsed = true;'
      bld.separate

      bld.start_function('constructor()')

      features = {}
      rootNode = NavigationNode.new('', '/')

      for mdl in ProjectPlanManager.current.models
        for otherCls in mdl.classes
          if otherCls.plugName.start_with?('class_angular_listing')
            plug = XCTEPlugin.findClassPlugin('typescript', otherCls.plugName)

            featureName = otherCls.featureGroup
            featureName = cls.model.name if featureName.nil?

            formattedFeatureName = featureName.capitalize
            curNode = findChildNode(rootNode, formattedFeatureName)

            if curNode.nil?
              curNode = NavigationNode.new(formattedFeatureName, nil)
              rootNode.children.push(curNode)
            end

            editPath = plug.get_full_route(otherCls, 'listing')
            curNode.children.push(NavigationNode.new(formattedFeatureName + ' listing', editPath))
          elsif otherCls.plugName.start_with?('class_angular_reactive_edit')
            plug = XCTEPlugin.findClassPlugin('typescript', otherCls.plugName)

            featureName = otherCls.featureGroup
            featureName = cls.model.name if featureName.nil?

            featureName = cls.variant + ' ' + featureName if !cls.variant.nil?

            formattedFeatureName = featureName.capitalize
            curNode = findChildNode(rootNode, formattedFeatureName)

            if curNode.nil?
              curNode = NavigationNode.new(formattedFeatureName, nil)
              rootNode.children.push(curNode)
            end

            editPath = plug.get_full_route(otherCls, 'edit')
            curNode.children.push(NavigationNode.new(featureName.capitalize + ' create', editPath))
          end
        end
      end

      bld.add 'var newNode: NavNode;'
      bld.add 'var cNode: NavNode;'

      for nd in rootNode.children
        renderAddNodeLine(bld, nd, 'newNode', 'this.navNode')

        for cnd in nd.children
          renderAddNodeLine(bld, cnd, 'cNode', 'newNode')
        end
      end

      bld.endFunction

      bld.separate

      bld.start_function 'addNode(toNode: NavNode, name: string, link: string | null)'
      bld.add 'var newNode = new NavNode(name, link);'
      bld.add 'toNode.children.push(newNode);'
      bld.add 'return newNode;'
      bld.endFunction

      bld.end_class
    end

    def findChildNode(rootNode, formattedFeatureName)
      if !rootNode.children.nil?
        for node in rootNode.children
          return node if node.name == formattedFeatureName
        end
      end

      nil
    end

    def renderAddNodeLine(bld, nd, assignTo, addToNode)
      if !nd.link.nil?
        bld.add(assignTo + ' = this.addNode(' + addToNode + ', "' + nd.name + '", "' + nd.link + '");')
      else
        bld.add(assignTo + ' = this.addNode(' + addToNode + ', "' + nd.name + '", null);')
      end
    end
  end
end

XCTEPlugin.registerPlugin(XCTETypescript::ClassAngularNavbar.new)
