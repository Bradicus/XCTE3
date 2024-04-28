##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "data list" classes

require "plugins_core/lang_cpp/utils"
require "plugins_core/lang_cpp/method_empty"
require "plugins_core/lang_cpp/x_c_t_e_cpp"

require "code_structure/code_elem_model"
require "code_structure/code_elem_var_group"
require "code_structure/code_elem_parent"
require "lang_file"
require "x_c_t_e_plugin"

module XCTECpp
  class ClassDataList < XCTEPlugin
    def initialize
      @name = "data_list"
      @language = "cpp"
      @category = XCTEPlugin::CAT_CLASS
    end

    def get_unformatted_class_name(cls)
      cls.get_u_name + " container"
    end

    def gen_source_files(cls)
      srcFiles = []

      # Use the standard class once we've added the necessary components
      stdClass = XCTEPlugin.findClassPlugin("cpp", "class_standard")

      listInfo = XCTECpp::Utils.getDataListInfo(cls.data_node)

      #      puts "Var name is: " << listInfo['varClassName']
      #      puts "Template type is: " << listInfo['cppTemplateType']

      cls.includesList.push(CodeElemInclude.new(cls.coreClass, ""))

      cls.includesList.push(CodeElemInclude.new(listInfo["cppTemplateType"], "")) if !listInfo["cppTemplateType"].nil?

      #      newGroup = CodeStructure::CodeElemVarGroup.new
      #      newVar = CodeElemVariable.new
      #      newVar.name = cls.coreClass[0,1].downcase! + cls.coreClass[1,1000] + "List"
      #      newVar.vtype = cls.coreClass;
      #      newVar.templateType = listInfo['cppTemplateType'];
      #      newGroup.vars.push(newVar);

      containerClass = CodeElemParent.new(cls.coreClass + "Container", "public")
      # containerClass.name =
      # containerClass.visibility = "public"

      cls.parentsList << containerClass

      #      cls.groups << newGroup

      listHFile = LangFile.new
      listHFile.lfName = cls.get_u_name
      listHFile.lfExtension = XCTECpp::Utils.get_extension("header")
      listHFile.lfContents = stdClass.render_header_comment(cls, cfg)
      listHFile.lfContents << stdClass.render_header(cls, cfg)

      listCppFile = LangFile.new
      listCppFile.lfName = cls.get_u_name
      listCppFile.lfExtension = XCTECpp::Utils.get_extension("body")
      listCppFile.lfContents = stdClass.render_header_comment(cls, cfg)
      listCppFile.lfContents << stdClass.render_body_content(cls, cfg)

      #      srcFiles << hFile
      #      srcFiles << cppFile

      srcFiles << listHFile
      srcFiles << listCppFile

      srcFiles
    end
  end
end

XCTEPlugin.registerPlugin(XCTECpp::ClassDataList.new)
