##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This plugin creates a set meathod for a class

require 'x_c_t_e_plugin'
require 'plugins_core/lang_ruby/x_c_t_e_ruby'

class XCTERuby::MethodXCTEGenSrouceFiles < XCTEPlugin
  def initialize
    @name = 'method_xcte_gen_src'
    @language = 'ruby'
    @category = XCTEPlugin::CAT_METHOD
  end

  # Returns declairation string for this class's set method
  def get_declaration(_codeClass, bld)
    bld.add('##')
    bld.add('# This class generates a definition for this function')
    bld.start_class('def render_function(codeClass, bld)')
    bld.add('varArray = Array.new')
    bld.add('codeClass.getAllVarsFor(varArray)')
    bld.add

    bld.start_block('for varSec in varArray')
    bld.start_block('if varSec.elementId == CodeElem::ELEM_VARIABLE')
    bld.start_block('if !varSec.isPointer')
    bld.start_block('if varSec.arrayElemCount == 0')
    bld.end_block
    bld.end_block
    bld.end_block
    bld.start_block('elsif varSec.elementId == CodeElem::ELEM_COMMENT')
    bld.add('bld.add(XCTERuby::Utils::getComment(varSec))')
    bld.unindent
    bld.start_block('elsif varSec.elementId == CodeElem::ELEM_COMMENT')
    bld.add('bld.same_line(varSec.formatText)')
    bld.end_block
    bld.end_block
    bld.end_class
  end

  # Returns definition string for this class's set method
  def render_function(codeClass, bld)
  end
end

# Now register an instance of our plugin
XCTEPlugin.registerPlugin(XCTERuby::MethodXCTEGenSrouceFiles.new)
