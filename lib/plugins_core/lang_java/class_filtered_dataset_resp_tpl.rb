##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "standard" classes,
# those being regualar classes for now, vs possible library specific
# class generators, such as a wxWidgets class generator or a Fox Toolkit
# class generator for example

require "plugins_core/lang_java/utils.rb"
require "plugins_core/lang_java/x_c_t_e_java.rb"
require "code_elem.rb"
require "code_elem_parent.rb"
require "code_elem_model.rb"
require "lang_file.rb"

module XCTEJava
  class ClassFilteredDatasetRespTpl < ClassBase
    def initialize
      @name = "class_filtered_dataset_resp_tpl"
      @language = "java"
      @category = XCTEPlugin::CAT_CLASS
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " resp tpl"
    end

    def process_dependencies(cls, bld)
      cls.addUse("java.util.List")
      super
    end

    # Returns the code for the header for this class
    def genFileContent(cls, bld)
      headerString = String.new

      bld.separate
      bld.startClass("public class " + getClassName(cls) + "<T>")

      model = InternalClassModelManager.findModel("page response")

      # Generate class variables
      eachVar(uevParams().wCls(model).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        bld.add(Utils.instance.getVarDec(var))
      }))

      bld.endClass
    end
  end
end

XCTEPlugin::registerPlugin(XCTEJava::ClassFilteredDatasetRespTpl.new)