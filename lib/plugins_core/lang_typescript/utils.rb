##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require "lang_profile.rb"
require "utils_base"
require "types"
require "code_elem_variable"

module XCTETypescript
  class Utils < UtilsBase
    include Singleton

    def initialize
      super("typescript")
    end

    # Get a parameter declaration for a method parameter
    def getParamDec(var)
      vDec = String.new
      typeName = String.new

      vDec << getStyledVariableName(var)
      vDec << ": " + getTypeName(var)

      if var.arrayElemCount.to_i > 0 && var.vtype != "String"
        vDec << "[]"
      end

      if var.comment != nil
        vDec << "\t/** " << var.comment << " */"
      end

      return vDec
    end

    def addParamIfAvailable(params, var)
      if (var != nil)
        params.push("private " + getParamDec(var))
      end
    end

    def getParamDecForClass(cls, plug)
      pDec = String.new
      pDec << CodeNameStyling.getStyled(plug.getUnformattedClassName(cls), @langProfile.variableNameStyle) << ": "

      pDec << plug.getClassName(cls)

      return pDec
    end

    # Returns variable declaration for the specified variable
    def getVarDec(var)
      vDec = String.new
      typeName = String.new

      if var.isConst
        vDec << "const "
      end

      if var.isStatic
        vDec << "static "
      end

      vDec << getStyledVariableName(var)
      vDec << ": " + getTypeName(var)

      if (var.defaultValue != nil)
        vDec << " = " << var.defaultValue
      end

      vDec << ";"

      if var.comment != nil
        vDec << "\t/** " << var.comment << " */"
      end

      return vDec
    end

    # Returns a size constant for the specified variable
    def getSizeConst(var)
      return "ARRAYSZ_" << var.name.upcase
    end

    # Get a type name for a variable
    def getTypeName(var)
      typeName = getSingleItemTypeName(var)

      if var.isList()
        typeName = apply_template(var.templates[0], typeName)
      end

      return typeName
    end

    def getSingleItemTypeName(var)
      typeName = getBaseTypeName(var)

      singleTpls = var.templates
      if var.isList()
        singleTpls = singleTpls.drop(1)
      end

      for tpl in singleTpls.reverse()
        typeName = apply_template(tpl, typeName)
      end

      return typeName
    end

    def apply_template(tpl, curTypeName)
      tplType = @langProfile.getTypeName(tpl.name)
      if tpl.name.downcase == "list"
        typeName = curTypeName + "[]"
      else
        typeName = tplType + "<" + curTypeName + ">"
      end

      return typeName
    end

    # Return the language type based on the generic type
    def getBaseTypeName(var)
      nsPrefix = ""

      baseTypeName = ""
      if (var.vtype != nil)
        baseTypeName = @langProfile.getTypeName(var.vtype)
      else
        baseTypeName = CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle)
      end

      baseTypeName = nsPrefix + baseTypeName

      return baseTypeName
    end

    def getListTypeName(listTypeName)
      return @langProfile.getTypeName(listTypeName)
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

    # process variable group
    def getFormgroup(cls, bld, vGroup, separator = ";")
      bld.sameLine("new FormGroup({")
      bld.indent

      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if isPrimitive(var)
          hasMult = var.isList()
          if !var.isList()
            bld.add(genPrimitiveFormControl(var) + ",")
          else
            bld.add(getStyledVariableName(var) + ": new FormArray([]),")
          end
        else
          otherClass = Classes.findVarClass(var, "ts_interface")

          if !var.isList()
            bld.add(getStyledVariableName(var) + ": ")
            if otherClass != nil
              getFormgroup(otherClass, bld, otherClass.model.varGroup, ",")
            else
              bld.sameLine("new FormControl(''),")
            end
          else
            bld.add(getStyledVariableName(var) + ": new FormArray([]),")
          end
        end
      }))

      bld.unindent
      bld.add("})" + separator)
    end

    def genPrimitiveFormControl(var)
      validators = []
      if var.required
        validators << "Validators.required"
      end
      if var.arrayElemCount > 0
        validators << "Validators.maxLength(" + var.arrayElemCount.to_s + ")"
      end

      vdString = ""
      if validators.length > 0
        vdString = ", [" + validators.join(", ") + "]"
      end

      if var.getUType().downcase().start_with?("date")
        return getStyledVariableName(var) + ": new FormControl<Date>(new Date()" + vdString + ")"
      else
        if Types.instance.inCategory(var, "text") || var.getUType().downcase == "guid"
          return getStyledVariableName(var) + ": new FormControl<" + getBaseTypeName(var) + ">(''" + vdString + ")"
        elsif var.getUType().downcase == "boolean"
          return getStyledVariableName(var) + ": new FormControl<" + getBaseTypeName(var) + ">(false)"
        end
        return getStyledVariableName(var) + ": new FormControl<" + getBaseTypeName(var) + ">(0" + vdString + ")"
      end
    end

    def getStyledUrlName(name)
      return CodeNameStyling.getStyled(name, "DASH_LOWER")
    end

    def isNumericPrimitive(var)
      isPrim = @langProfile.isPrimitive(var)
      isNum = Types.instance.inCategory(var, "number")
      return isPrim && isNum
    end

    def addClassnamesFor(clsList, cls, language, classType)
      for otherCls in cls.model.classes
        if otherCls.ctype == classType
          plug = XCTEPlugin::findClassPlugin(language, classType)
          clsList.push(plug.getClassName(otherCls))
        end
      end
    end

    def renderClassList(clsList, bld)
      firstLine = true
      uniqueList = clsList.uniq()

      for c in uniqueList
        if !firstLine
          bld.sameLine(",")
        end

        bld.iadd(c)
        firstLine = false
      end
    end

    def getOptionsVarFor(var)
      optVar = var.clone
      optVar.name = optVar.name + " options"
      optVar.utype = var.selectFrom
      optVar.vtype = nil
      optVar.defaultValue = "of([])"
      optVar.templates = Array.new
      optVar.addTpl("Observable")
      optVar.addTpl("List", true)

      return optVar
    end
  end
end
