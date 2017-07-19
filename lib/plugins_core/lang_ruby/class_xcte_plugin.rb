##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "XCTEPlugin" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require 'plugins_core/lang_ruby/utils.rb'
require 'plugins_core/lang_ruby/source_renderer_ruby.rb'
require 'plugins_core/lang_ruby/x_c_t_e_ruby.rb'
require 'code_elem.rb'
require 'code_elem_parent.rb'
require 'code_elem_model.rb'
require 'lang_file.rb'

class XCTERuby::ClassXCTEPlugin < XCTEPlugin
  def initialize
    XCTERuby::Utils::init

    @name = "xcte_plugin"
    @language = "ruby"
    @category = XCTEPlugin::CAT_CLASS
    @author = "Brad Ottoson"
  end

  def genSourceFiles(codeClass, cfg)
    srcFiles = Array.new

    codeBuilder = SourceRendererRuby.new
    codeBuilder.lfName = codeClass.name
    codeBuilder.lfExtension = XCTERuby::Utils::getExtension('body')
    genFileComment(codeClass, cfg, codeBuilder)
    genFileContent(codeClass, cfg, codeBuilder)

    srcFiles << codeBuilder

    return srcFiles
  end

  def genFileComment(codeClass, cfg, codeBuilder)
    codeBuilder.add("##")
    codeBuilder.add("# Class:: " + codeClass.name)

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

    if (codeClass.description != nil)
      codeClass.description.each_line { |descLine|
        if descLine.strip.size > 0
          headerString.add("# " + descLine.chomp)
        end
      }
    end
  end

  # Returns the code for the content for this class
  def genFileContent(codeClass, cfg, codeBuilder)
    
    for inc in codeClass.includesList
      codeBuilder.add("require '" + inc.path + inc.name + "." + XCTERuby::Utils::getExtension('body') + "'")
    end

    if !codeClass.includesList.empty?
      codeBuilder.add
    end

    codeBuilder.startClass("class XCTERuby::Class" + codeClass.name + " < XCTEPlugin")
    
    codeBuilder.startFunction("def initialize")
    codeBuilder.add("XCTERuby::Utils::init")
    codeBuilder.add
    codeBuilder.add('@name = ""')
    codeBuilder.add('@language = ""')
    codeBuilder.add('@category = XCTEPlugin::CAT_CLASS')
    codeBuilder.add('@author = ""')
    codeBuilder.endFunction
    codeBuilder.add

    codeBuilder.startFunction("def genSourceFiles(codeClass, cfg)")
    codeBuilder.add("srcFiles = Array.new")
    codeBuilder.add
    codeBuilder.add("codeBuilder = SourceRendererRuby.new")
    codeBuilder.add("codeBuilder.lfName = codeClass.name")
    codeBuilder.add("codeBuilder.lfExtension = XCTERuby::Utils::getExtension('body')")
    codeBuilder.add("genRubyFileComment(codeClass, cfg, codeBuilder)")
    codeBuilder.add("genRubyFileContent(codeClass, cfg, codeBuilder)")
    codeBuilder.add
    codeBuilder.add("srcFiles << rubyFile")
    codeBuilder.add
    codeBuilder.add("return srcFiles")
    codeBuilder.endFunction
    codeBuilder.add

    codeBuilder.add("# Returns the code for the content for this class")
    codeBuilder.startFunction("def genFileContent(codeClass, cfg, codeBuilder)")
    codeBuilder.add
    codeBuilder.startBlock("for inc in codeClass.includesList")
    codeBuilder.add('codeBuilder.add("require \'" + inc.path + inc.name + "." + XCTERuby::Utils::getExtension(\'body\') + "\'")')
    codeBuilder.endBlock
    codeBuilder.add
    codeBuilder.startBlock("if !codeClass.includesList.empty?")
    codeBuilder.add("codeBuilder.add")
    codeBuilder.endBlock
    codeBuilder.add

    codeBuilder.add('varArray = Array.new')
    codeBuilder.add('codeClass.getAllVarsFor(cfg, varArray);')

    codeBuilder.startBlock("if codeClass.hasAnArray")
    codeBuilder.add('codeBuilder.add  # If we declaired array size variables add a seperator')
    codeBuilder.endBlock

    codeBuilder.add('# Generate class variables')
    codeBuilder.add('codeBuilder.add("    # -- Variables --")')

    codeBuilder.startBlock("for var in varArray")
    codeBuilder.startBlock('if var.elementId == CodeElem::ELEM_VARIABLE')
    codeBuilder.add('codeBuilder.add("    " + XCTERuby::Utils::getVarDec(var))')
    codeBuilder.midBlock('elsif var.elementId == CodeElem::ELEM_COMMENT')
    codeBuilder.add('codeBuilder.sameLine("    " +  XCTERuby::Utils::getComment(var))')
    codeBuilder.midBlock('elsif var.elementId == CodeElem::ELEM_FORMAT')
    codeBuilder.add('codeBuilder.add(var.formatText)')
    codeBuilder.endBlock
    codeBuilder.endBlock

    codeBuilder.add("codeBuilder.add")

    codeBuilder.add("# Generate code for functions")
    codeBuilder.startBlock("for fun in codeClass.functionSection")
      codeBuilder.startBlock("if fun.elementId == CodeElem::ELEM_FUNCTION")
        codeBuilder.startBlock("if fun.isTemplate")
          codeBuilder.add('templ = XCTEPlugin::findMethodPlugin("ruby", fun.name)')
          codeBuilder.add('if templ != nil')
            codeBuilder.iadd(1, 'codeBuilder.add(templ.get_definition(codeClass, cfg))')
          codeBuilder.add('else')
            codeBuilder.add("#puts 'ERROR no plugin for function: ' + fun.name + '   language: java'")
          codeBuilder.add('end')
        codeBuilder.midBlock('else  # Must be empty function')
          codeBuilder.add('templ = XCTEPlugin::findMethodPlugin("ruby", "method_empty")')
          codeBuilder.startBlock('if templ != nil')
            codeBuilder.add('codeBuilder.add(templ.get_definition(fun, cfg))')
          codeBuilder.midBlock('else')
            codeBuilder.add("#puts 'ERROR no plugin for function: ' + fun.name + '   language: java'")
          codeBuilder.endBlock
        codeBuilder.endBlock
      codeBuilder.endBlock
    codeBuilder.endBlock

    codeBuilder.add("end  # class  + codeClass.name")
    codeBuilder.add
    codeBuilder.endBlock

    codeBuilder.endBlock
    codeBuilder.add

    codeBuilder.add("XCTEPlugin::registerPlugin(XCTERuby::Class" + codeClass.name + " < XCTEPlugin.new)")
  end
end

XCTEPlugin::registerPlugin(XCTERuby::ClassXCTEPlugin.new)
