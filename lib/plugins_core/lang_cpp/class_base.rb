require "plugins_core/lang_cpp/utils.rb"
require "x_c_t_e_plugin.rb"

# This class contains functions that may be usefull in any type of class
module XCTECpp
  class ClassBase < XCTEPlugin
    def genIfndef(cls, hFile)
      if (cls.namespaceList != nil)
        hFile.add("#ifndef _" + cls.namespaceList.join("_") + "_" + Utils.instance.getStyledClassName(cls.name) + "_H")
        hFile.add("#define _" + cls.namespaceList.join("_") + "_" + Utils.instance.getStyledClassName(cls.name) + "_H")
        hFile.add
      else
        hFile.add("#ifndef _" + cls.name + "_H")
        hFile.add("#define _" + cls.name + "_H")
        hFile.add
      end
    end

    def genIncludes(cls, cfg, hFile)
      addAutoIncludes(cls, cfg)

      for inc in cls.includes
        if (inc.path.length > 0)
          incPathAndName = inc.path + "/" + inc.name
        else
          incPathAndName = inc.name
        end

        if inc.itype == "<"
          hFile.add("#include <" << incPathAndName << ">")
        elsif inc.name.count(".") > 0
          hFile.add('#include "' << incPathAndName << '"')
        else
          hFile.add('#include "' << incPathAndName << "." << Utils.instance.getExtension("header") << '"')
        end
      end
    end

    def genUsings(cls, cfg, hFile)
      for us in cls.uses
        hFile.add("using namespace " + us.namespace.split(".").join("::") + ";")
      end
    end

    def addAutoIncludes(cls, cfg)
      varArray = Array.new

      for vGrp in cls.model.groups
        CodeStructure::CodeElemModel.getVarsFor(vGrp, varArray)
      end

      for var in varArray
        if (var.respond_to? :vtype)
          varTypeMap = Utils.instance.getType(var.vtype)
          if (varTypeMap != nil && !varTypeMap.autoInclude.name.nil? && !varTypeMap.autoInclude.name.empty?)
            cls.addInclude(varTypeMap.autoInclude.path, varTypeMap.autoInclude.name, varTypeMap.autoInclude.itype)
          end
        end
      end
    end
  end
end
