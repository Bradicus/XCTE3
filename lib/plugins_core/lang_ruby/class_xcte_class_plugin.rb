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
      return cls.model.name
    end

    def genSourceFiles(cls, cfg)
      srcFiles = Array.new

      codeBuilder = SourceRendererRuby.new
      codeBuilder.lfName = cls.name
      codeBuilder.lfExtension = Utils.instance.getExtension("body")
      genFileComment(cls, cfg, codeBuilder)
      genFileContent(cls, cfg, codeBuilder)

      srcFiles << codeBuilder

      return srcFiles
    end

    def genFileComment(cls, cfg, codeBuilder)
      codeBuilder.add("##")
      codeBuilder.add("# Class:: " + cls.name)

      if cfg.codeAuthor != nil
        codeBuilder.add("# Author:: " + cfg.codeAuthor)
      end

      if cfg.codeCompany != nil && cfg.codeCompany.size > 0
        codeBuilder.add("# " + cfg.codeCompany)
      end

      if cfg.codeLicense != nil && cfg.codeLicense.size > 0
        codeBuilder.add("#")
        codeBuilder.add("# License:: " + cfg.codeLicense)
      end

      codeBuilder.add("#")

      if (cls.description != nil)
        cls.description.each_line { |descLine|
          if descLine.strip.size > 0
            headerString.add("# " + descLine.chomp)
          end
        }
      end
    end

    # Returns the code for the content for this class
    def genFileContent(cls, cfg, codeBuilder)
      for inc in cls.includes
        codeBuilder.add("require '" + inc.path + inc.name + "." + Utils.instance.getExtension("body") + "'")
      end

      if !cls.includes.empty?
        codeBuilder.add
      end

      codeBuilder.startClass("class XCTERuby::Class" + Utils.instance.getStyledClassName(cls.model.name) + " < XCTEPlugin")

      codeBuilder.startFunction("def initialize")
      codeBuilder.add("Utils.instance.init")
      codeBuilder.add
      codeBuilder.add('@name = "' + CodeNameStyling.styleUnderscoreLower(cls.model.name) + '"')
      codeBuilder.add('@language = "' + cls.xmlElement.attributes["lang"] + '"')
      codeBuilder.add("@category = XCTEPlugin::CAT_CLASS")
      if cfg.codeAuthor
        codeBuilder.add('@author = "' + cfg.codeAuthor + '"')
      end
      codeBuilder.endFunction
      codeBuilder.add

      codeBuilder.startFunction("def genSourceFiles(cls, cfg)")
      codeBuilder.add("srcFiles = Array.new")
      codeBuilder.add
      codeBuilder.add("codeBuilder = SourceRendererRuby.new")
      codeBuilder.add("codeBuilder.lfName = cls.name")
      codeBuilder.add("codeBuilder.lfExtension = Utils.instance.getExtension('body')")
      codeBuilder.add("genRubyFileComment(cls, cfg, codeBuilder)")
      codeBuilder.add("genRubyFileContent(cls, cfg, codeBuilder)")
      codeBuilder.add
      codeBuilder.add("srcFiles << rubyFile")
      codeBuilder.add
      codeBuilder.add("return srcFiles")
      codeBuilder.endFunction
      codeBuilder.add

      codeBuilder.add("# Returns the code for the content for this class")
      codeBuilder.startFunction("def genFileContent(cls, cfg, codeBuilder)")
      codeBuilder.add
      codeBuilder.startBlock("for inc in cls.includesList")
      codeBuilder.add('codeBuilder.add("require \'" + inc.path + inc.name + "." + Utils.instance.getExtension(\'body\') + "\'")')
      codeBuilder.endBlock
      codeBuilder.add
      codeBuilder.startBlock("if !cls.includesList.empty?")
      codeBuilder.add("codeBuilder.add")
      codeBuilder.endBlock
      codeBuilder.add

      codeBuilder.add("varArray = Array.new")
      codeBuilder.add("cls.getAllVarsFor(varArray);")

      codeBuilder.startBlock("if cls.hasAnArray")
      codeBuilder.add("codeBuilder.add  # If we declaired array size variables add a seperator")
      codeBuilder.endBlock

      codeBuilder.add("# Generate class variables")
      codeBuilder.add('codeBuilder.add("    # -- Variables --")')

      codeBuilder.startBlock("for var in varArray")
      codeBuilder.startBlock("if var.elementId == CodeElem::ELEM_VARIABLE")
      codeBuilder.add('codeBuilder.add("    " + Utils.instance.getVarDec(var))')
      codeBuilder.midBlock("elsif var.elementId == CodeElem::ELEM_COMMENT")
      codeBuilder.add('codeBuilder.sameLine("    " +  Utils.instance.getComment(var))')
      codeBuilder.midBlock("elsif var.elementId == CodeElem::ELEM_FORMAT")
      codeBuilder.add("codeBuilder.add(var.formatText)")
      codeBuilder.endBlock
      codeBuilder.endBlock

      codeBuilder.add("codeBuilder.add")

      codeBuilder.add("# Generate code for functions")
      codeBuilder.startBlock("for fun in cls.functionSection")
      codeBuilder.startBlock("if fun.elementId == CodeElem::ELEM_FUNCTION")
      codeBuilder.startBlock("if fun.isTemplate")
      codeBuilder.add('templ = XCTEPlugin::findMethodPlugin("ruby", fun.name)')
      codeBuilder.add("if templ != nil")
      codeBuilder.iadd(1, "codeBuilder.add(templ.get_definition(cls, cfg))")
      codeBuilder.add("else")
      codeBuilder.add("#puts 'ERROR no plugin for function: ' + fun.name + '   language: java'")
      codeBuilder.add("end")
      codeBuilder.midBlock("else  # Must be empty function")
      codeBuilder.add('templ = XCTEPlugin::findMethodPlugin("ruby", "method_empty")')
      codeBuilder.startBlock("if templ != nil")
      codeBuilder.add("codeBuilder.add(templ.get_definition(fun, cfg))")
      codeBuilder.midBlock("else")
      codeBuilder.add("#puts 'ERROR no plugin for function: ' + fun.name + '   language: java'")
      codeBuilder.endBlock
      codeBuilder.endBlock
      codeBuilder.endBlock
      codeBuilder.endBlock

      codeBuilder.add("end  # class  + cls.name")
      codeBuilder.add
      codeBuilder.endBlock

      codeBuilder.endBlock
      codeBuilder.add

      codeBuilder.add("XCTEPlugin::registerPlugin(XCTERuby::Class" + cls.name + " < XCTEPlugin.new)")
    end
  end
end

XCTEPlugin::registerPlugin(XCTERuby::ClassXCTEClassPlugin.new)
