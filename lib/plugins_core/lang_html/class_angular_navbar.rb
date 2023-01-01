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
      return cls.getUName() + " navbar"
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
      bld.startBlock('<nav class="navbar">')
      bld.startBlock('<div class="container-fluid">')

      # Generate table body
      bld.startBlock('<div class="collapse navbar-collapse"')
      bld.startBlock('<ul class="navbar-nav">')

      bld.startBlock('<li class="nav-item">')
      bld.add('<a class="nav-link active" aria-current="page" href="#">Home</a>')
      bld.endBlock("</li>")
      for group in cls.model.groups
        process_var_group_menu(cls, bld, group)
      end
      bld.endBlock("</ul>")
      bld.endBlock("</div>")
      bld.endBlock("</div>")

      bld.endBlock("</nav>")

      bld.add
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
