##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "class_standard" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require "plugins_core/lang_php/utils"
require "plugins_core/lang_php/x_c_t_e_php"

require "code_structure/code_elem_parent"
require "lang_file"

module XCTEPhp
  class ClassStandard < ClassBase
    def initialize
      @name = "class_standard"
      @language = "php"
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name
    end

    # Returns the code for the header for this class
    def render_body_content(codeClass, outCode)
      outCode.add

      for inc in codeClass.includes
        outCode.add('include_once("' << inc.path << inc.name << '.php");')
      end

      if !codeClass.includes.empty?
        outCode.add("")
      end

      outCode.add("class " << get_class_name(codeClass))
      outCode.add("{")

      render_functions(codeClass, outCode)

      outCode.add("}")
    end
  end
end

XCTEPlugin.registerPlugin(XCTEPhp::ClassStandard.new)
