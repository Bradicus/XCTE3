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

module XCTETypescript
  class Utils < UtilsBase
    include Singleton

    def initialize
      super("typescript")
    end

    # Get a parameter declaration for a method parameter
    def getParamDec(var)
      pDec = String.new

      pDec << getTypeName(var.vtype)

      pDec << " " << var.name

      if var.arrayElemCount > 0
        pDec << "[]"
      end

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

      if var.arrayElemCount.to_i > 0 && var.vtype != "String"
        vDec << "[" + getSizeConst(var) << "]"
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

      if (var.listType != nil)
        typeName = "[]"
      end

      return typeName
    end

    def getSingleItemTypeName(var)
      typeName = ""
      baseTypeName = getBaseTypeName(var)

      if (var.templateType != nil)
        typeName = var.templateType + "<" + baseTypeName + ">"
      end

      if (typeName.length == 0)
        typeName = baseTypeName
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

    def isPrimitive(var)
      return @langProfile.isPrimitive(var)
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
    def getFormgroup(cls, bld, vGroup)
      bld.sameLine("this.fb.group({")
      bld.indent

      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          if isPrimitive(var)
            if var.listType == nil
              bld.add(getStyledVariableName(var) + ": [''],")
            else
              bld.add(getStyledVariableName(var) + ": this.fb.array([]),")
            end
          else
            otherClass = Classes.findVarClass(var)

            if var.listType == nil
              bld.add(getStyledVariableName(var) + ": ")
              if otherClass != nil
                for group in otherClass.model.groups
                  getFormgroup(otherClass, bld, group)
                  bld.sameLine(",")
                end
              else
                bld.sameLine("[''],")
              end
            else
              bld.add(getStyledVariableName(var) + ": this.fb.array([]),")
            end
          end
        end
        # for group in vGroup.groups
        #   process_var_group(cls, cfg, bld, group)
        # end
      end

      bld.unindent
      bld.add("})")
    end

    # process variable group
    def genPopulate(cls, bld, vGroup, name = "")
      for var in vGroup.vars
        if var.elementId == CodeElem::ELEM_VARIABLE
          if isPrimitive(var)
            if var.listType == nil
              bld.add(name + getStyledVariableName(var) + " = " + getFakerAssignment(var) + ";")
            else
              bld.add(name + getStyledVariableName(var) + ".push_back(" + getFakerAssignment(var) + ");")
            end
          else
            otherClass = Classes.findVarClass(var)

            if var.listType == nil
              bld.separate
              bld.add(name + getStyledVariableName(var) + " = {} as " + getStyledClassName(var.getUType()) + ";")
              if otherClass != nil
                for group in otherClass.model.groups
                  genPopulate(otherClass, bld, group, name + getStyledVariableName(var) + ".")
                end
              else
              end
            else
              bld.separate
              bld.add(name + getStyledVariableName(var) + "= [];")
            end
          end
        end
        # for group in vGroup.groups
        #   process_var_group(cls, cfg, bld, group)
        # end
      end
    end

    def getStyledUrlName(name)
      return CodeNameStyling.getStyled(name, "DASH_LOWER")
    end

    def isPrimitive(var)
      return @langProfile.isPrimitive(var)
    end

    def isNumericPrimitive(var)
      return @langProfile.isPrimitive(var) && Types.instance.inCategory(var, "numeric")
    end

    def getFakerAssignment(var)
      varType = var.getUType().downcase()

      if isNumericPrimitive(var)
        return "faker.random.numeric(8)"
      elsif (varType.start_with?("datetime"))
        return "faker.date.recent()"
      elsif var.name.include? "first name"
        return "faker.name.firstName()"
      elsif var.name.include? "last name"
        return "faker.name.lastName()"
      elsif var.name.include? "city"
        return "faker.address.city()"
      elsif var.name.include? "country"
        return "faker.address.country()"
      elsif var.name.include? "county"
        return "faker.address.county()"
      elsif var.name.include? "email"
        return 'faker.name.firstName() + "." + faker.name.lastName() + "@example.com"'
      end

      return "faker.random.alpha(11)"
    end
  end
end
