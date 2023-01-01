##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "XCTEPlugin" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require "plugins_core/lang_ruby/utils.rb"
require "plugins_core/lang_ruby/source_renderer_ruby.rb"
require "plugins_core/lang_ruby/x_c_t_e_ruby.rb"
require "code_elem.rb"
require "code_elem_parent.rb"
require "code_elem_model.rb"
require "lang_file.rb"

module XCTERuby
  class ClassXCTEClassPlugin < XCTEPlugin
    def initialize
      @name = "xcte_class_plugin"
      @language = "ruby"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.getUName()
    end

    def genSourceFiles(cls)
      srcFiles = Array.new

      bld = SourceRendererRuby.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))
      bld.lfExtension = Utils.instance.getExtension("body")
      genFileComment(cls, bld)
      genFileContent(cls, bld)

      srcFiles << bld

      return srcFiles
    end

    def genFileComment(cls, bld)
      bld.add("##")
      bld.add("# Class:: " + cls.name)

      if UserSettings.instance.codeAuthor != nil
        bld.add("# Author:: " + UserSettings.instance.codeAuthor)
      end

      if UserSettings.instance.codeCompany != nil && UserSettings.instance.codeCompany.size > 0
        bld.add("# " + UserSettings.instance.codeCompany)
      end

      if UserSettings.instance.codeLicense != nil && UserSettings.instance.codeLicense.strip.size > 0
        bld.add("#")
        bld.add("# License:: " + UserSettings.instance.codeLicense)
      end

      bld.add("#")

      # if (UserSettings.instance.description != nil)
      #   UserSettings.instance.description.each_line { |descLine|
      #     if descLine.strip.size > 0
      #       headerString.add("# " + descLine.chomp)
      #     end
      #   }
      # end
    end

    # Returns the code for the content for this class
    def genFileContent(cls, bld)
      for inc in cls.includes
        bld.add("require '" + inc.path + inc.name + "." + Utils.instance.getExtension("body") + "'")
      end

      if !cls.includes.empty?
        bld.add
      end

      # Process namespace items
      if cls.namespace.hasItems?()
        for nsItem in cls.namespace.nsList
          bld.startBlock("module " << nsItem)
        end
      end

      bld.startClass("class " + getClassName(cls) + " < ClassBase")

      bld.startFunction("def initialize")
      bld.add('@name = "' + CodeNameStyling.styleUnderscoreLower(cls.getUName()) + '"')
      bld.add('@language = "' + cls.xmlElement.attributes["lang"] + '"')
      bld.add("@category = XCTEPlugin::CAT_CLASS")
      if UserSettings.instance.codeAuthor
        bld.add('@author = "' + UserSettings.instance.codeAuthor + '"')
      end
      bld.endFunction
      bld.separate

      bld.startFunction("def getUnformattedClassName(cls)")
      bld.add("return cls.getUName()")
      bld.endFunction

      bld.add

      bld.startFunction("def genSourceFiles(cls)")
      bld.add("srcFiles = Array.new")
      bld.separate
      bld.add("bld = SourceRenderer" +
              CodeNameStyling.getStyled(cls.xmlElement.attributes["lang"], "PASCAL_CASE") + ".new")
      bld.add("bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))")
      bld.add("bld.lfExtension = Utils.instance.getExtension('body')")
      bld.separate
      bld.add("process_dependencies(cls, bld)")
      bld.add("render_dependencies(cls, bld)")
      bld.separate
      bld.add("genFileComment(cls, bld)")
      bld.add("genFileContent(cls, bld)")
      bld.add
      bld.add("srcFiles << bld")
      bld.add
      bld.add("return srcFiles")
      bld.endFunction
      bld.add

      bld.add("# Returns the code for the comment for this class")
      bld.startFunction("def genFileComment(cls, bld)")
      bld.add
      bld.endFunction
      bld.add

      bld.add("# Returns the code for the content for this class")
      bld.startFunction("def genFileContent(cls, bld)")

      bld.add('bld.startClass("class " + getClassName(cls))')
      bld.separate
      bld.add("bld.separate")

      bld.add("# Generate code for class variables")
      bld.add("eachVar(uevParams().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|")
      bld.add("}))")

      bld.separate
      bld.add("bld.separate")

      bld.add("# Generate code for functions")
      bld.add("render_functions(cls, bld)")

      bld.separate

      bld.add("bld.endClass")
      bld.endFunction
      bld.add

      bld.separate

      bld.endBlock

      # Process namespace items
      if cls.namespace.hasItems?()
        for nsItem in cls.namespace.nsList
          bld.endBlock
        end
      end

      bld.separate

      prefix = cls.namespace.get("::")

      if (prefix.size > 0)
        prefix += "::"
      end

      bld.add("XCTEPlugin::registerPlugin(" + prefix + getClassName(cls) + ".new)")
    end
  end
end

XCTEPlugin::registerPlugin(XCTERuby::ClassXCTEClassPlugin.new)
