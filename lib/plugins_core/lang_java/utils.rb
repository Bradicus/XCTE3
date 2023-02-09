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

    def requires_var(cls, var, ctype)
      varClass = cls.model.findClassByType(ctype)
      requires_other_class_type(cls, varClass, ctype)
    end

    def requires_other_class_type(cls, otherCls, ctype)
      ctypeClass = cls.model.findClassByType(ctype)
      if !cls.namespace.same?(ctypeClass.namespace)
        cls.addUse(ctypeClass.namespace.get(".") + ".*")
      end
    end

    def requires_class_type(cls, ctype)
      ctypeClass = cls.model.findClassByType(ctype)

      if (ctypeClass == nil)
        Log.error("unable to find class by type " + ctype)
      else
        cls.addUse(ctypeClass.namespace.get(".") + ".*")
      end
    end

    def addClassInjection(cls, ctype)
      varClass = cls.model.findClassByType(ctype)
      if varClass != nil
        var = createVarFor(varClass, ctype)
        var.visibility = "private"

        if var != nil
          cls.addInjection(var)
          requires_var(cls, varClass, ctype)
        end
      else
        Log.error("Unable to find class type " + ctype + " for model " + cls.model.name)
      end
    end
  end
end
