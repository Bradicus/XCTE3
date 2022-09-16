##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class generates source files for "data list" classes

require "plugins_core/lang_cpp/utils.rb"
require "plugins_core/lang_cpp/method_empty.rb"
require "plugins_core/lang_cpp/x_c_t_e_cpp.rb"
require "code_elem.rb"
require "code_elem_model.rb"
require "code_elem_var_group.rb"
require "code_elem_parent.rb"
require "lang_file.rb"
require "x_c_t_e_plugin.rb"

module XCTECpp
  class ClassDataList < XCTEPlugin
    def initialize
      @name = "data_list"
      @language = "cpp"
      @category = XCTEPlugin::CAT_CLASS
      @author = "Brad Ottoson"
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def getUnformattedClassName(cls)
      return cls.getUName() + " container"
    end

    def getClassName(cls)
      return Utils.instance.getStyledClassName(getUnformattedClassName(cls))
    end

    def genSourceFiles(codeClass, cfg)
      srcFiles = Array.new

      # Use the standard class once we've added the necessary components
      stdClass = XCTEPlugin.findClassPlugin("cpp", "standard")

      listInfo = XCTECpp::Utils::getDataListInfo(codeClass.xmlElement)

      #      puts "Var name is: " << listInfo['varClassName']
      #      puts "Template type is: " << listInfo['cppTemplateType']

      codeClass.includesList.push(CodeElemInclude.new(codeClass.coreClass, ""))

      if (listInfo["cppTemplateType"] != nil)
        codeClass.includesList.push(CodeElemInclude.new(listInfo["cppTemplateType"], ""))
      end

      #      newGroup = CodeStructure::CodeElemVarGroup.new
      #      newVar = CodeElemVariable.new
      #      newVar.name = codeClass.coreClass[0,1].downcase! + codeClass.coreClass[1,1000] + "List"
      #      newVar.vtype = codeClass.coreClass;
      #      newVar.templateType = listInfo['cppTemplateType'];
      #      newGroup.vars.push(newVar);

      containerClass = CodeElemParent.new(codeClass.coreClass + "Container", "public")
      #containerClass.name =
      #containerClass.visibility = "public"

      codeClass.parentsList << containerClass

      #      codeClass.groups << newGroup

      listHFile = LangFile.new
      listHFile.lfName = codeClass.name
      listHFile.lfExtension = XCTECpp::Utils::getExtension("header")
      listHFile.lfContents = stdClass.genHeaderComment(codeClass, cfg)
      listHFile.lfContents << stdClass.genHeader(codeClass, cfg)

      listCppFile = LangFile.new
      listCppFile.lfName = codeClass.name
      listCppFile.lfExtension = XCTECpp::Utils::getExtension("body")
      listCppFile.lfContents = stdClass.genHeaderComment(codeClass, cfg)
      listCppFile.lfContents << stdClass.genBody(codeClass, cfg)

      #      srcFiles << hFile
      #      srcFiles << cppFile

      srcFiles << listHFile
      srcFiles << listCppFile

      return srcFiles
    end
  end
end

XCTEPlugin::registerPlugin(XCTECpp::ClassDataList.new)
