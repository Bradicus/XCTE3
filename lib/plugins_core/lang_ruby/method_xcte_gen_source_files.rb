##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a set meathod for a class

require 'x_c_t_e_plugin.rb'
require 'plugins_core/lang_ruby/x_c_t_e_ruby.rb'

class XCTERuby::MethodXCTEGenSrouceFiles < XCTEPlugin

  def initialize
    @name = "method_xcte_gen_src"
    @language = "ruby"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's set method
  def get_declaration(codeClass, cfg, codeBuilder)
    codeBuilder.add("##")
    codeBuilder.add("# This class generates a definition for this function")
    codeBuilder.startClass("def get_definition(codeClass, cfg, codeBuilder)")
    codeBuilder.add("varArray = Array.new")
    codeBuilder.add("codeClass.getAllVarsFor(cfg, varArray)")
    codeBuilder.add

    codeBuilder.startBlock("for varSec in varArray")
      codeBuilder.startBlock('if varSec.elementId == CodeElem::ELEM_VARIABLE')
        codeBuilder.startBlock('if !varSec.isPointer')
          codeBuilder.startBlock('if varSec.arrayElemCount == 0')
          codeBuilder.endBlock
        codeBuilder.endBlock
      codeBuilder.endBlock
      codeBuilder.startBlock('elsif varSec.elementId == CodeElem::ELEM_COMMENT')
        codeBuilder.add('codeBuilder.add(XCTERuby::Utils::getComment(varSec))')
      codeBuilder.unindent
      codeBuilder.startBlock('elsif varSec.elementId == CodeElem::ELEM_COMMENT')
        codeBuilder.add('codeBuilder.sameLine(varSec.formatText)')
      codeBuilder.endBlock
    codeBuilder.endBlock
    codeBuilder.endClass
  end

  # Returns definition string for this class's set method
  def get_definition(codeClass, cfg, codeBuilder)
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTERuby::MethodXCTEGenSrouceFiles.new)
