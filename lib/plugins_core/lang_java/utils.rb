##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require "lang_profile.rb"
require "utils_base"
require "log"
require "ref_finder"

module XCTEJava
  class Utils < UtilsBase
    include Singleton

    def initialize
      super("java")
    end

    # Get a parameter declaration for a method parameter
    def getParamDec(var)
      pDec = String.new

      pDec << getTypeName(var)

      pDec << " " << self.getStyledVariableName(var)

      return pDec
    end

    # Returns variable declaration for the specified variable
    def getVarDec(var)
      vDec = String.new

      vDec << var.visibility << " "

      if var.isConst
        vDec << "const "
      end

      if var.isStatic
        vDec << "static "
      end

      if var.isVirtual
        vDec << "virtual "
      end

      vDec << getTypeName(var)

      vDec << " "

      if var.nullable
        vDec << "?"
      end

      vDec << self.getStyledVariableName(var)
      vDec << ";"

      if var.comment != nil
        vDec << "\t/** " << var.comment << " */"
      end

      return vDec
    end

    # def getFullType(var)
    #   fType = ""

    #   if (var.templateType != nil)
    #     fType << var.templateType << "<" << self.getTypeName(var) << ">"
    #   elsif (var.listType != nil)
    #     fType << var.listType << "<" << self.getTypeName(var) << ">"
    #   else
    #     fType << self.getTypeName(var)
    #   end
    # end

    def getFullOjbType(var)
      fType = ""

      if (var.templateType != nil)
        fType += var.templateType + "<" + self.getTypeName(var) + ">"
      elsif (var.listType != nil)
        fType += var.listType + "<" + self.getTypeName(var) + ">"
      else
        fType += self.getTypeName(var)
      end
    end

    # Return the language type based on the generic type
    def getTypeName(var)
      typeName = getSingleItemTypeName(var)

      if var.templates.length > 0 && var.templates[0].isCollection
        tplType = @langProfile.getTypeName(var.templates[0].name)
        typeName = tplType + "<" + typeName + ">"
      end

      return typeName
    end

    def getSingleItemTypeName(var)
      typeName = getBaseTypeName(var)

      singleTpls = var.templates
      if singleTpls.length > 0 && singleTpls[0].isCollection
        singleTpls = singleTpls.drop(1)

        if isPrimitive(var)
          typeName = getObjTypeName(var)
        end
      end

      for tpl in singleTpls.reverse()
        typeName = tpl.name + "<" + typeName + ">"
      end

      return typeName.strip
    end

    # Return the language type based on the generic type
    def getBaseTypeName(var)
      nsPrefix = ""
      langType = @langProfile.getTypeName(var.getUType())

      if (var.utype != nil) # Only unformatted name needs styling
        baseTypeName = CodeNameStyling.getStyled(langType, @langProfile.classNameStyle)
      else
        baseTypeName = langType
      end

      if var.namespace.hasItems?()
        nsPrefix = var.namespace.get("::") + "::"
        baseTypeName = nsPrefix + baseTypeName
      end

      return baseTypeName
    end

    # Return the language type based on the generic type
    def getObjTypeName(var)
      if (var.vtype != nil)
        objType = getType(var.vtype + "obj")
        if (objType != nil)
          return objType.langType
        end

        return @langProfile.getTypeName(var.vtype)
      else
        return CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle)
      end
    end

    # Returns a size constant for the specified variable
    def getSizeConst(var)
      return CodeNameStyling.getStyled("max len " + var.name, @langProfile.constNameStyle)
    end

    # Get the extension for a file type
    def getExtension(eType)
      return @langProfile.getExtension(eType)
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def getComment(var)
      return "/* " << var.text << " */\n"
    end

    # Capitalizes the first letter of a string
    def getCapitalizedFirst(str)
      newStr = String.new
      newStr += str[0, 1].capitalize

      if (str.length > 1)
        newStr += str[1..str.length - 1]
      end

      return(newStr)
    end

    def getStyledUrlName(name)
      return CodeNameStyling.getStyled(name, "DASH_LOWER")
    end

    def process_var_dependencies(cls, bld, vGroup)
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          if !isPrimitive(var)
            varCls = Classes.findVarClass(var)
            fPath = getStyledFileName(var.getUType() + "")
            cls.addInclude(varCls.path + "/" + fPath + ".module", getStyledClassName(var.getUType() + " module"))
          end
        end
      end

      for grp in vGroup.varGroups
        process_var_dependencies(cls, bld, grp)
      end
    end

    def requires_var(cls, var)
      #varClass = Classes.findVarClass(var)
      varClassAndPlug = RefFinder.find_class_by_type(cls.genCfg.language, var.getUType())
      #requires_other_class_type(cls, varClass, varClass.plug.name)

      if varClassAndPlug != nil && !cls.namespace.same?(varClassAndPlug.cls.namespace)
        cls.addUse(varClassAndPlug.cls.namespace.get(".") + ".*")
      end
    end

    def requires_other_class_type(cls, otherCls, plugName)
      plugNameClass = cls.model.findClassByType(plugName)
      if !cls.namespace.same?(plugNameClass.namespace)
        cls.addUse(plugNameClass.namespace.get(".") + ".*")
      end
    end

    def requires_class_type(cls, fromCls, plugName)
      plugNameClass = fromCls.model.findClassByType(plugName)

      if (plugNameClass == nil)
        Log.error("unable to find class by type " + plugName)
      else
        cls.addUse(plugNameClass.namespace.get(".") + ".*")
      end
    end

    def requires_class_ref(cls, classRef)
      plugNameClass = Classes.findClass(classRef.className, classRef.pluginName)

      if (plugNameClass == nil)
        Log.error("unable to find class by ref ")
      else
        cls.addUse(plugNameClass.namespace.get(".") + ".*")
      end
    end

    def get_data_class(cls)
      if (cls.model.derivedFrom != nil)
        derived = Classes.findClass(cls.model.derivedFrom, "class_jpa_entity")

        if (derived != nil)
          return derived
        else
          Log.error("Derived class not found for class " + cls.model.derivedFrom + "  plugin: class_jpa_entity")
        end
      end

      return cls
    end

    def add_class_injection(toCls, fromCls, plugName)
      varClass = fromCls.model.findClassByType(plugName)
      if varClass != nil
        var = createVarFor(varClass, plugName)
        var.visibility = "private"

        if var != nil
          toCls.addInjection(var)
          requires_var(toCls, var)
        end
      else
        Log.error("Unable to find class type " + plugName + " for model " + cls.model.name)
      end
    end
  end
end
