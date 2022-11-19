##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a set meathod for a class

require "x_c_t_e_plugin.rb"
require "plugins_core/lang_ruby/x_c_t_e_ruby.rb"

class XCTERuby::MethodXCTEGenSrouceFiles < XCTEPlugin
  def initialize
    @name = "method_xcte_gen_src"
    @language = "ruby"
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's set method
  def get_declaration(codeClass, cfg, bld)
    bld.add("##")
    bld.add("# This class generates a definition for this function")
    bld.startClass("def get_definition(codeClass, cfg, bld)")
    bld.add("varArray = Array.new")
    bld.add("codeClass.getAllVarsFor(varArray)")
    bld.add

    bld.startBlock("for varSec in varArray")
    bld.startBlock("if varSec.elementId == CodeElem::ELEM_VARIABLE")
    bld.startBlock("if !varSec.isPointer")
    bld.startBlock("if varSec.arrayElemCount == 0")
    bld.endBlock
    bld.endBlock
    bld.endBlock
    bld.startBlock("elsif varSec.elementId == CodeElem::ELEM_COMMENT")
    bld.add("bld.add(XCTERuby::Utils::getComment(varSec))")
    bld.unindent
    bld.startBlock("elsif varSec.elementId == CodeElem::ELEM_COMMENT")
    bld.add("bld.sameLine(varSec.formatText)")
    bld.endBlock
    bld.endBlock
    bld.endClass
  end

  # Returns definition string for this class's set method
  def get_definition(codeClass, cfg, bld)
  end
end

# Now register an instance of our plugin
XCTEPlugin::registerPlugin(XCTERuby::MethodXCTEGenSrouceFiles.new)
