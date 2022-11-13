##
# Class:: ClassAngularNavBar
#
module XCTEHtml
  class ClassAngularNavBar < XCTEPlugin
    def initialize
      @name = "class_angular_navbar"
      @language = "html"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " navbar"
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      bld = SourceRendererHtml.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls) + ".component")
      bld.lfExtension = Utils.instance.getExtension("body")
      #genFileComment(cls, cfg, bld)
      genFileContent(cls, cfg, bld)

      srcFiles << bld

      return srcFiles
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, bld)
      bld.startBlock('<nav class="navbar">')
      bld.startBlock('<div class="container-fluid">')

      # Generate table body
      bld.startBlock('<div class="collapse navbar-collapse"')
      bld.startBlock('<ul class="navbar-nav">')

      bld.startBlock('<li class="nav-item">')
      bld.add('<a class="nav-link active" aria-current="page" href="#">Home</a>')
      bld.endBlock("</li>")
      for group in cls.model.groups
        process_var_group_menu(cls, cfg, bld, group)
      end
      bld.endBlock("</ul>")
      bld.endBlock("</div>")
      bld.endBlock("</div>")

      bld.endBlock("</nav>")

      bld.add
    end

    # process variable group
    def process_var_group_menu(cls, cfg, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          varName = Utils.instance.getStyledVariableName(var)

          bld.startBlock('<li class="nav-item">')
          bld.add('<a class="nav-link active" aria-current="page" href="#">' + var.name + "</a>")
          bld.endBlock("</li>")
        end
        for group in vGroup.groups
          process_var_group_body(cls, cfg, bld, group)
        end
      end
    end
  end
end

XCTEPlugin::registerPlugin(XCTEHtml::ClassAngularNavBar.new)