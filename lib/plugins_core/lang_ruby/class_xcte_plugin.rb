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
require 'code_elem_class.rb'
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

    codeGen = SourceRendererRuby.new
    codeGen.lfName = codeClass.name
    codeGen.lfExtension = XCTERuby::Utils::getExtension('body')
    genFileComment(codeClass, cfg, codeGen)
    genFileContent(codeClass, cfg, codeGen)

    srcFiles << codeGen

    return srcFiles
  end

  def genFileComment(codeClass, cfg, codeGen)
    codeGen.add("##")
    codeGen.add("# Class:: " + codeClass.name)

    if cfg.codeAuthor != nil
      codeGen.add("# Author:: " + cfg.codeAuthor)
    end

    if cfg.codeCompany != nil && cfg.codeCompany.size > 0
      codeGen.add("# " + cfg.codeCompany)
    end

    if cfg.codeLicense != nil && cfg.codeLicense.size > 0
      codeGen.add("#")
      codeGen.add("# License:: " + cfg.codeLicense)
    end

    codeGen.add("#")

    if (codeClass.description != nil)
      codeClass.description.each_line { |descLine|
        if descLine.strip.size > 0
          headerString.add("# " + descLine.chomp)
        end
      }
    end
  end

  # Returns the code for the content for this class
  def genFileContent(codeClass, cfg, codeGen)
    
    for inc in codeClass.includesList
      codeGen.add("require '" + inc.path + inc.name + "." + XCTERuby::Utils::getExtension('body') + "'")
    end

    if !codeClass.includesList.empty?
      codeGen.add
    end

    codeGen.startClass("class XCTERuby::Class" + codeClass.name + " < XCTEPlugin")
    
    codeGen.startFunction("def initialize")
    codeGen.add("XCTERuby::Utils::init")
    codeGen.add
    codeGen.add('@name = ""')
    codeGen.add('@language = ""')
    codeGen.add('@category = XCTEPlugin::CAT_CLASS')
    codeGen.add('@author = ""')
    codeGen.endFunction    
    codeGen.add

    codeGen.startFunction("def genSourceFiles(codeClass, cfg)")
    codeGen.add("srcFiles = Array.new")
    codeGen.add
    codeGen.add("codeGen = SourceRendererRuby.new")
    codeGen.add("codeGen.lfName = codeClass.name")
    codeGen.add("codeGen.lfExtension = XCTERuby::Utils::getExtension('body')")
    codeGen.add("genRubyFileComment(codeClass, cfg, codeGen)")
    codeGen.add("genRubyFileContent(codeClass, cfg, codeGen)")
    codeGen.add
    codeGen.add("srcFiles << rubyFile")
    codeGen.add
    codeGen.add("return srcFiles")
    codeGen.endFunction
    codeGen.add

    codeGen.add("# Returns the code for the content for this class")
    codeGen.startFunction("def genFileContent(codeClass, cfg, codeGen)")
    codeGen.add    
    codeGen.startBlock("for inc in codeClass.includesList")
    codeGen.add('codeGen.add("require \'" + inc.path + inc.name + "." + XCTERuby::Utils::getExtension(\'body\') + "\'")')
    codeGen.endBlock
    codeGen.add
    codeGen.startBlock("if !codeClass.includesList.empty?")
    codeGen.add("codeGen.add")
    codeGen.endBlock
    codeGen.add

    codeGen.add('varArray = Array.new')
    codeGen.add('codeClass.getAllVarsFor(cfg, varArray);')

    codeGen.startBlock("if codeClass.hasAnArray")
    codeGen.add('codeGen.add  # If we declaired array size variables add a seperator')
    codeGen.endBlock

    codeGen.add('# Generate class variables')
    codeGen.add('codeGen.add("    # -- Variables --")')

    codeGen.startBlock("for var in varArray")
    codeGen.startBlock('if var.elementId == CodeElem::ELEM_VARIABLE')
    codeGen.add('codeGen.add("    " + XCTERuby::Utils::getVarDec(var))')
    codeGen.midBlock('elsif var.elementId == CodeElem::ELEM_COMMENT')
    codeGen.add('codeGen.sameLine("    " +  XCTERuby::Utils::getComment(var))')
    codeGen.midBlock('elsif var.elementId == CodeElem::ELEM_FORMAT')
    codeGen.add('codeGen.add(var.formatText)')
    codeGen.endBlock
    codeGen.endBlock

    codeGen.add("codeGen.add")

    codeGen.add("# Generate code for functions")
    codeGen.startBlock("for fun in codeClass.functionSection")
      codeGen.startBlock("if fun.elementId == CodeElem::ELEM_FUNCTION")
        codeGen.startBlock("if fun.isTemplate")
          codeGen.add('templ = XCTEPlugin::findMethodPlugin("ruby", fun.name)')
          codeGen.add('if templ != nil')
            codeGen.iadd(1, 'codeGen.add(templ.get_definition(codeClass, cfg))')
          codeGen.add('else')
            codeGen.add("#puts 'ERROR no plugin for function: ' + fun.name + '   language: java'")
          codeGen.add('end')
        codeGen.midBlock('else  # Must be empty function')
          codeGen.add('templ = XCTEPlugin::findMethodPlugin("ruby", "method_empty")')
          codeGen.startBlock('if templ != nil')
            codeGen.add('codeGen.add(templ.get_definition(fun, cfg))')
          codeGen.midBlock('else')
            codeGen.add("#puts 'ERROR no plugin for function: ' + fun.name + '   language: java'")
          codeGen.endBlock
        codeGen.endBlock
      codeGen.endBlock
    codeGen.endBlock

    codeGen.add("end  # class  + codeClass.name")
    codeGen.add
    codeGen.endBlock

    codeGen.endBlock
    codeGen.add

    codeGen.add("XCTEPlugin::registerPlugin(XCTERuby::Class" + codeClass.name + " < XCTEPlugin.new)")
  end
end

XCTEPlugin::registerPlugin(XCTERuby::ClassXCTEPlugin.new)
