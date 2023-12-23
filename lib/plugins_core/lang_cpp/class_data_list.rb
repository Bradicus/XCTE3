##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "data list" classes

require 'plugins_core/lang_cpp/utils'
require 'plugins_core/lang_cpp/method_empty'
require 'plugins_core/lang_cpp/x_c_t_e_cpp'
require 'code_elem'
require 'code_elem_model'
require 'code_elem_var_group'
require 'code_elem_parent'
require 'lang_file'
require 'x_c_t_e_plugin'

module XCTECpp
  class ClassDataList < XCTEPlugin
    def initialize
      @name = 'data_list'
      @language = 'cpp'
      @category = XCTEPlugin::CAT_CLASS
      @author = 'Brad Ottoson'
    end

    def get_unformatted_class_name(cls)
      cls.getUName + ' container'
    end

    def genSourceFiles(cls)
      srcFiles = []

      # Use the standard class once we've added the necessary components
      stdClass = XCTEPlugin.findClassPlugin('cpp', 'standard')

      listInfo = XCTECpp::Utils.getDataListInfo(cls.xmlElement)

      #      puts "Var name is: " << listInfo['varClassName']
      #      puts "Template type is: " << listInfo['cppTemplateType']

      cls.includesList.push(CodeElemInclude.new(cls.coreClass, ''))

      cls.includesList.push(CodeElemInclude.new(listInfo['cppTemplateType'], '')) if !listInfo['cppTemplateType'].nil?

      #      newGroup = CodeStructure::CodeElemVarGroup.new
      #      newVar = CodeElemVariable.new
      #      newVar.name = cls.coreClass[0,1].downcase! + cls.coreClass[1,1000] + "List"
      #      newVar.vtype = cls.coreClass;
      #      newVar.templateType = listInfo['cppTemplateType'];
      #      newGroup.vars.push(newVar);

      containerClass = CodeElemParent.new(cls.coreClass + 'Container', 'public')
      # containerClass.name =
      # containerClass.visibility = "public"

      cls.parentsList << containerClass

      #      cls.groups << newGroup

      listHFile = LangFile.new
      listHFile.lfName = cls.name
      listHFile.lfExtension = XCTECpp::Utils.getExtension('header')
      listHFile.lfContents = stdClass.genHeaderComment(cls, cfg)
      listHFile.lfContents << stdClass.genHeader(cls, cfg)

      listCppFile = LangFile.new
      listCppFile.lfName = cls.name
      listCppFile.lfExtension = XCTECpp::Utils.getExtension('body')
      listCppFile.lfContents = stdClass.genHeaderComment(cls, cfg)
      listCppFile.lfContents << stdClass.genBody(cls, cfg)

      #      srcFiles << hFile
      #      srcFiles << cppFile

      srcFiles << listHFile
      srcFiles << listCppFile

      srcFiles
    end
  end
end

XCTEPlugin.registerPlugin(XCTECpp::ClassDataList.new)
