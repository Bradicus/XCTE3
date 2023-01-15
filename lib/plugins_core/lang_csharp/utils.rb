##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains the language profile for CSharp and utility fuctions
# used by various plugins

require "lang_profile.rb"
require "code_name_styling.rb"
require "utils_base.rb"
require "singleton"

module XCTECSharp
  class Utils < UtilsBase
    include Singleton

    def initialize
      super("csharp")
    end

    # Get a parameter declaration for a method parameter
    def getParamDec(var)
      pDec = String.new

      pDec << self.getTypeName(var)

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

      if (var.templateType != nil)
        vDec << var.templateType << "<" << self.getTypeName(var) << ">"
      elsif (var.listType != nil)
        vDec << var.listType << "<" << self.getTypeName(var) << ">"
      else
        vDec << self.getTypeName(var)
      end

      vDec << " "

      if var.nullable
        vDec << "?"
      end

      vDec << self.getStyledVariableName(var)

      if (var.genGet != nil || var.genSet != nil)
        vDec << " { "
        if (var.genGet != nil)
          vDec << "get; "
        end
        if (var.genSet != nil)
          vDec << "set; "
        end
        vDec << "}"
      else
        vDec << ";"
      end

      if var.comment != nil
        vDec << "\t/** " << var.comment << " */"
      end

      return vDec
    end

    def addClassInclude(cls, ctype)
      cls.addUse(cls.model.findClassByType(ctype).namespace.get("."))
    end

    # Returns a size constant for the specified variable
    def getSizeConst(var)
      return "ARRAYSZ_" << var.name.upcase
    end

    # Returns the version of this name styled for this language
    def getStyledVariableName(var, varPrefix = "")
      if var.is_a?(CodeStructure::CodeElemVariable)
        if (var.genGet || var.genSet)
          return CodeNameStyling.getStyled(varPrefix + var.name, @langProfile.functionNameStyle)
        else
          return CodeNameStyling.getStyled(varPrefix + var.name, @langProfile.variableNameStyle)
        end
      else
        return CodeNameStyling.getStyled(var, @langProfile.variableNameStyle)
      end
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

    # Get the extension for a file type
    def getExtension(eType)
      return @langProfile.getExtension(eType)
    end

    def getComment(var)
      return "/* " << var.text << " */\n"
    end

    # Should move this into language def xml
    def getZero(var)
      if var.vtype == "Float32"
        return "0.0f"
      end
      if var.vtype == "Float64"
        return "0.0"
      end

      return "0"
    end

    def getDataListInfo(classXML)
      dInfo = Hash.new

      classXML.elements.each("DATA_LIST_TYPE") { |dataListXML|
        dInfo["csharpTemplateType"] = dataListXML.attributes["csharpTemplateType"]
      }

      return(dInfo)
    end

    # generate use list for file
    def genUses(useList, bld)
      for use in useList
        bld.add("using " + use.namespace.get(".") + ";")
      end

      if !useList.empty?
        bld.add
      end
    end

    def genFunctionDependencies(cls, bld)
      # Add in any dependencies required by functions
      for fun in cls.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin::findMethodPlugin("csharp", fun.name)
            if templ != nil
              templ.process_dependencies(cls, bld, fun)
            else
              puts "ERROR no plugin for function: " + fun.name + "   language: csharp"
            end
          end
        end
      end
    end

    def addNonIdentityParams(cls, bld)
      varArray = Array.new
      cls.model.getNonIdentityVars(varArray)

      addParameters(varArray, cls, bld)
    end

    def addParameters(varArray, cls, bld)
      for var in varArray
        if var.elementId == CodeElem::ELEM_VARIABLE
          bld.add('cmd.Parameters.AddWithValue("@' +
                  Utils.instance.getStyledVariableName(var) +
                  '", o.' + Utils.instance.getStyledVariableName(var) + ");")
        else
          if var.elementId == CodeElem::ELEM_FORMAT
            bld.add(var.formatText)
          end
        end
      end
    end

    # Generate a list of @'d parameters
    def genParamList(cls, bld, varPrefix = "")
      separator = ""
      # Process variables
      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        bld.sameLine(separator)
        bld.add("@" + getStyledVariableName(var, varPrefix))
        separator = ","
      }))
    end

    # Generate a list of variables
    def genVarList(cls, bld, varPrefix = "")
      separator = ""
      # Process variables
      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        bld.sameLine(separator)
        bld.add("[" + XCTETSql::Utils.instance.getStyledVariableName(var, varPrefix) + "]")
        separator = ","
      }))
    end

    def genAssignResults(cls, bld)
      Utils.instance.eachVar(UtilsEachVarParams.new().wCls(cls).wBld(bld).wSeparate(true).wVarCb(lambda { |var|
        if var.elementId == CodeElem::ELEM_VARIABLE && var.isList() && isPrimitive(var)
          resultVal = 'results["' +
                      XCTETSql::Utils.instance.getStyledVariableName(var, cls.varPrefix) + '"]'
          objVar = "o." + XCTECSharp::Utils.instance.getStyledVariableName(var)

          if var.nullable
            bld.add(objVar + " = " + resultVal + " == DBNull.Value ? null : Convert.To" +
                    var.vtype + "(" + resultVal + ");")
          else
            bld.add(objVar + " = Convert.To" +
                    var.vtype + "(" + resultVal + ");")
          end
        end
      }))
    end

    def genFunctions(cls, bld)
      # Generate code for functions
      for fun in cls.functions
        if fun.elementId == CodeElem::ELEM_FUNCTION
          if fun.isTemplate
            templ = XCTEPlugin::findMethodPlugin("csharp", fun.name)
            if templ != nil
              templ.get_definition(cls, fun, nil, bld)
            else
              puts "ERROR no plugin for function: " + fun.name + "   language: csharp"
            end
          else # Must be empty function
            templ = XCTEPlugin::findMethodPlugin("csharp", "method_empty")
            if templ != nil
              templ.get_definition(cls, fun, nil, bld)
            else
              #puts 'ERROR no plugin for function: ' + fun.name + '   language: csharp'
            end
          end

          bld.add
        end
      end
    end

    def genNamespaceStart(namespace, bld)
      # Process namespace items
      if namespace.hasItems?()
        bld.startBlock("namespace " << namespace.get("."))
      end
    end

    def genNamespaceEnd(namespace, bld)
      if namespace.hasItems?()
        bld.endBlock(" // namespace " + namespace.get("."))
        bld.add
      end
    end

    def getLangugageProfile
      return @langProfile
    end

    def getClassTypeName(cls)
      nsPrefix = ""
      if cls.namespace.hasItems?()
        nsPrefix = cls.namespace.get(".") + "."
      end

      baseTypeName = CodeNameStyling.getStyled(cls.name, @langProfile.classNameStyle)
      baseTypeName = nsPrefix + baseTypeName

      if (cls.templateParams.length > 0)
        allParams = Array.new

        for param in cls.templateParams
          allParams.push(CodeNameStyling.getStyled(param.name, @langProfile.classNameStyle))
        end

        baseTypeName += "<" + allParams.join(", ") + ">"
      end

      return baseTypeName
    end

    # Retrieve the standard version of this model's class
    def getStandardClassInfo(cls)
      cls.standardClass = cls.model.findClassByType("standard")

      if (cls.standardClass.namespace.hasItems?())
        ns = cls.standardClass.namespace.get(".") + "."
      else
        ns = ""
      end

      cls.standardClassType = ns + Utils.instance.getStyledClassName(cls.getUName())

      if (cls.standardClass != nil && cls.standardClass.ctype != "enum")
        cls.addInclude(cls.standardClass.namespace.get("/"), Utils.instance.getStyledClassName(cls.getUName()))
      end

      return cls.standardClass
    end
  end
end
