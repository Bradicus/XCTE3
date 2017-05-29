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
    @author = "Brad Ottoson"
  end

  # Returns declairation string for this class's set method
  def get_declaration(codeClass, cfg, codeGen)
    codeGen.add("##")
    codeGen.add("# This class generates a definition for this function")
    codeGen.startClass("def get_definition(codeClass, cfg, codeGen)")
    codeGen.add("varArray = Array.new")
    codeGen.add("codeClass.getAllVarsFor(cfg, varArray)")
    codeGen.add

    codeGen.startBlock("for varSec in varArray")
      codeGen.startBlock('if varSec.elementId == CodeElem::ELEM_VARIABLE')
        codeGen.startBlock('if !varSec.isPointer')
          codeGen.startBlock('if varSec.arrayElemCount == 0')
          codeGen.endBlock
        codeGen.endBlock
      codeGen.endBlock
      codeGen.startBlock('elsif varSec.elementId == CodeElem::ELEM_COMMENT')
        codeGen.add('codeGen.add(XCTERuby::Utils::getComment(varSec))')
      codeGen.unindent
      codeGen.startBlock('elsif varSec.elementId == CodeElem::ELEM_COMMENT')
        codeGen.add('codeGen.sameLine(varSec.formatText)')
      codeGen.endBlock
    codeGen.endBlock
    codeGen.endClass
  end

  # Returns definition string for this class's set method
  def get_definition(codeClass, cfg, codeGen)
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTERuby::MethodXCTEGenSrouceFiles.new)
