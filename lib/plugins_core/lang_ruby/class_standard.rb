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

require "plugins_core/lang_ruby/x_c_t_e_ruby"
require "plugins_core/lang_ruby/utils"
require "plugins_core/lang_ruby/class_base"
require "x_c_t_e_plugin"

require "code_structure/code_elem_parent"
require "code_structure/code_elem_model"
require "lang_file"
require "log"

module XCTERuby
  class ClassStandard < ClassBase
    def initialize
      super

      @name = "class_standard"
      @language = "ruby"
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name
    end

    # Returns the code for the header for this class
    def render_body_content(cls, bld)
      inheritFrom = ""

      inheritFrom = " < " + Utils.instance.getClassTypeName(cls.base_classes[0]) if cls.base_classes.length > 0

      if cls.base_classes.length > 1
        Log.error("Ruby doesn't support multiple inheritance")
      end

      bld.start_class("class " + get_class_name(cls) + inheritFrom)

      accessors = Accessors.new

      # Render accessors
      each_var(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.genGet || var.genSet
          accessors.add(Accessor.new(var, var.genGet, var.genSet))
        end
      }))

      render_accessors("attr_accessor", accessors.both, bld)
      render_accessors("attr_attr_reader", accessors.readers, bld)
      render_accessors("attr_attr_writer", accessors.writers, bld)

      bld.separate

      # Generate class variables
      each_var(uevParams.wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        bld.add(Utils.instance.get_var_dec(var))
      }))

      bld.separate

      # Generate code for functions
      render_functions(cls, bld)

      bld.end_class
    end

    def render_accessors(accName, accList, bld)
      return unless accList.length > 0

      bld.render_wrappable_list(accName, get_accessor_var_list(accList), ", ")
    end

    def get_accessor_var_list(accList)
      vList = []

      for acc in accList
        vList.push(" :" + Utils.instance.get_styled_variable_name(acc.var))
      end

      vList
    end
  end
end

XCTEPlugin.registerPlugin(XCTERuby::ClassStandard.new)
