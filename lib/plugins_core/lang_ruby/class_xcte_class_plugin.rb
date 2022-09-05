##

#
# Copyright (C) 2008 Brad Ottoson
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

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      bld = SourceRendererRuby.new
      bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))
      bld.lfExtension = Utils.instance.getExtension("body")
      genFileComment(cls, cfg, bld)
      genFileContent(cls, cfg, bld)

      srcFiles << bld

      return srcFiles
    end

    def genFileComment(cls, cfg, bld)
      bld.add("##")
      bld.add("# Class:: " + cls.name)

      if cfg.codeAuthor != nil
        bld.add("# Author:: " + cfg.codeAuthor)
      end

      if cfg.codeCompany != nil && cfg.codeCompany.size > 0
        bld.add("# " + cfg.codeCompany)
      end

      if cfg.codeLicense != nil && cfg.codeLicense.size > 0
        bld.add("#")
        bld.add("# License:: " + cfg.codeLicense)
      end

      bld.add("#")

      if (cls.description != nil)
        cls.description.each_line { |descLine|
          if descLine.strip.size > 0
            headerString.add("# " + descLine.chomp)
          end
        }
      end
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, bld)
      for inc in cls.includes
        bld.add("require '" + inc.path + inc.name + "." + Utils.instance.getExtension("body") + "'")
      end

      if !cls.includes.empty?
        bld.add
      end

      # Process namespace items
      if cls.namespaceList != nil
        for nsItem in cls.namespaceList
          bld.startBlock("module " << nsItem)
        end
      end

      bld.startClass("class " + getClassName(cls) + " < XCTEPlugin")

      bld.startFunction("def initialize")
      bld.add('@name = "' + CodeNameStyling.styleUnderscoreLower(cls.getUName()) + '"')
      bld.add('@language = "' + cls.xmlElement.attributes["lang"] + '"')
      bld.add("@category = XCTEPlugin::CAT_CLASS")
      if cfg.codeAuthor
        bld.add('@author = "' + cfg.codeAuthor + '"')
      end
      bld.endFunction
      bld.add

      bld.startFunction("def getClassName(cls)")
      bld.add("return Utils.instance.getStyledClassName(getUnformattedClassName(cls))")
      bld.endFunction

      bld.add

      bld.startFunction("def getUnformattedClassName(cls)")
      bld.add("return cls.getUName()")
      bld.endFunction

      bld.add

      bld.startFunction("def genSourceFiles(cls, cfg)")
      bld.add("srcFiles = Array.new")
      bld.add
      bld.add("bld = SourceRenderer" +
              CodeNameStyling.getStyled(cls.xmlElement.attributes["lang"], "PASCAL_CASE") + ".new")
      bld.add("bld.lfName = Utils.instance.getStyledFileName(getUnformattedClassName(cls))")
      bld.add("bld.lfExtension = Utils.instance.getExtension('body')")
      bld.add("genFileComment(cls, cfg, bld)")
      bld.add("genFileContent(cls, cfg, bld)")
      bld.add
      bld.add("srcFiles << bld")
      bld.add
      bld.add("return srcFiles")
      bld.endFunction
      bld.add

      bld.add("# Returns the code for the comment for this class")
      bld.startFunction("def genFileComment(cls, cfg, bld)")
      bld.add
      bld.endFunction
      bld.add

      bld.add("# Returns the code for the content for this class")
      bld.startFunction("def genFileContent(cls, cfg, bld)")
      bld.separate
      bld.add("process_dependencies(cls, cfg, bld)")
      bld.separate
      bld.add("bld.separate")

      bld.add("# Generate class variables")
      bld.startBlock("for group in cls.model.groups")
      bld.add("process_var_group(cls, cfg, bld, group)")
      bld.endBlock

      bld.separate
      bld.add("bld.separate")

      bld.add("# Generate code for functions")

      bld.startBlock("for fun in cls.functions")
      bld.add("process_function(cls, cfg, bld, fun)")
      bld.endBlock

      bld.separate

      bld.add("bld.endClass")
      bld.endFunction
      bld.add

      bld.add("# process variable group")
      bld.startFunction("def process_var_group(cls, cfg, bld, vGroup)")
      bld.startBlock("for var in vGroup.vars")
      bld.startBlock("if var.elementId == CodeElem::ELEM_VARIABLE")
      bld.add("bld.add(Utils.instance.getVarDec(var))")
      bld.midBlock("elsif var.elementId == CodeElem::ELEM_COMMENT")
      bld.add("bld.sameLine(Utils.instance.getComment(var))")
      bld.midBlock("elsif var.elementId == CodeElem::ELEM_FORMAT")
      bld.add("bld.add(var.formatText)")
      bld.endBlock
      bld.endBlock
      bld.startBlock("for group in vGroup.groups")
      bld.add("process_var_group(cls, cfg, bld, group)")
      bld.endBlock
      bld.endFunction

      bld.separate

      bld.startFunction("def process_function(cls, cfg, bld, fun)")
      bld.startBlock("if fun.elementId == CodeElem::ELEM_FUNCTION")
      bld.startBlock("if fun.isTemplate")
      bld.add('templ = XCTEPlugin::findMethodPlugin("' + cls.xmlElement.attributes["lang"] + '", fun.name)')
      bld.add("if templ != nil")
      bld.iadd(1, "templ.get_definition(cls, cfg)")
      bld.add("else")
      bld.add("#puts 'ERROR no plugin for function: ' + fun.name + '   language: '" + cls.xmlElement.attributes["lang"])
      bld.add("end")
      bld.midBlock("else  # Must be empty function")
      bld.add('templ = XCTEPlugin::findMethodPlugin("' + cls.xmlElement.attributes["lang"] + '", "method_empty")')
      bld.startBlock("if templ != nil")
      bld.add("templ.get_definition(fun, cfg)")
      bld.midBlock("else")
      bld.add("#puts 'ERROR no plugin for function: ' + fun.name + '   language: '" + cls.xmlElement.attributes["lang"])
      bld.endBlock
      bld.endBlock
      bld.endBlock
      bld.endFunction
      bld.endBlock

      # Process namespace items
      if cls.namespaceList != nil
        for nsItem in cls.namespaceList
          bld.endBlock
        end
      end

      bld.add

      prefix = cls.namespaceList.join("::")

      if (prefix.size > 0)
        prefix += "::"
      end

      bld.add("XCTEPlugin::registerPlugin(" + prefix + getClassName(cls) + ".new)")
    end
  end
end

XCTEPlugin::registerPlugin(XCTERuby::ClassXCTEClassPlugin.new)
