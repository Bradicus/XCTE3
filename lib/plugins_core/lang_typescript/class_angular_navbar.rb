##
# Class:: ClassAngularNavbar
#
require "active_component"

module XCTETypescript
  class ClassAngularNavbar < ClassBase
    def initialize
      @name = "class_angular_navbar"
      @language = "typescript"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName()
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererTypescript.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))
      bld.lfExtension = Utils.instance.getExtension("body")

      process_dependencies(cls, bld)
      render_dependencies(cls, bld)

      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the comment for this class
    def genFileComment(cls, bld)
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      filePart = Utils.instance.getStyledFileName(cls.getUName())

      bld.startClass("class NavNode")
      bld.add("name: string;")
      bld.add("url?: string;")
      bld.add("children: NavNode[] = [];")

      bld.startFunction("constructor(name: string, url?: string)")

      bld.add("this.name = name;")
      bld.add("this.url = url;")
      bld.endFunction
      bld.endBlock

      bld.add("@Component({")
      bld.indent
      bld.add("selector: 'app-" + filePart + "',")
      bld.add("templateUrl: './" + filePart + ".component.html',")
      bld.add("styleUrls: ['./" + filePart + ".component.css']")
      bld.unindent
      bld.add("})")

      bld.startClass("class " + getClassName(cls))

      bld.add('public navNode:NavNode = new NavNode("");')

      bld.startFunction("constructor(aRoute: ActivatedRoute)")

      for otherCls in ActiveComponent.get().models
      end

      # constructor(aRoute: ActivatedRoute) {
      #   var roleNode = new NavNode("Role");
      #   var roleEdit = new NavNode("Edit", "/role/edit");
      #   roleNode.children.push(roleEdit);
      #   this.navNode.children.push(roleNode);

      bld.endFunction

      bld.endClass
    end
  end
end

XCTEPlugin::registerPlugin(XCTETypescript::ClassAngularNavbar.new)
