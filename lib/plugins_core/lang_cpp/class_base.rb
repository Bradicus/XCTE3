# This class contains functions that may be usefull in any type of class

class ClassBase
  def self.genIncludes(dataModel, genClass, cfg, hFile)
    addAutoIncludes(dataModel, genClass, cfg)

      for inc in genClass.includes
        if (inc.path.length > 0)
          incPathAndName = inc.path + '/' + inc.name
        else
          incPathAndName = inc.name
        end

        if inc.itype == '<'
          hFile.add("#include <" << incPathAndName << '>')
        elsif inc.name.count(".") > 0
          hFile.add('#include "' << incPathAndName << '"')
        else
          hFile.add('#include "' << incPathAndName << "." << XCTECpp::Utils::getExtension('header') << '"')
        end
      end
  end

  def self.addAutoIncludes(dataModel, genClass, cfg)
    varArray = Array.new

    for vGrp in dataModel.groups
      CodeStructure::CodeElemModel.getVarsFor(vGrp, cfg, varArray)
    end

    for var in varArray
      varTypeMap = XCTECpp::Utils.langProfile.getType(var.vtype)
      if (varTypeMap != nil && !varTypeMap.autoInclude.name.nil? && !varTypeMap.autoInclude.name.empty?)
        genClass.addInclude(varTypeMap.autoInclude.path, varTypeMap.autoInclude.name, varTypeMap.autoInclude.itype)
      end
    end
  end
end