##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require 'lang_profile'
require 'utils_base'
require 'singleton'

module XCTETSql
  class Utils < UtilsBase
    include Singleton

    def initialize
      super('tsql')
    end

    # Returns variable declaration for the specified variable
    def getVarDec(var, varPrefix)
      vDec = String.new
      if varPrefix.nil?
        vPrevix = ''
      else
        vPrevix = varPrefix
      end
      if var.hasOneToOneRelation
        vDec << '[' << CodeNameStyling.getStyled(vPrevix + var.name + ' id', @langProfile.variableNameStyle) << ']'
      elsif var.hasManyToManyRelation
        return ''
      else
        vDec << '[' << CodeNameStyling.getStyled(vPrevix + var.name, @langProfile.variableNameStyle) << ']'
      end

      tName = getTypeName(var)

      if tName != var.vtype
        vDec << ' ' + tName
        if var.identity
          vDec << ' IDENTITY' << var.identity
        end
      else
        vDec << ' TEXT'
      end

      return vDec
    end

    # Get a parameter declaration for a method parameter
    def getTypeName(var)
      if isPrimitive(var)
        if var.vtype == 'String'
          return('VARCHAR(MAX)') if var.arrayElemCount > 9999

          return('VARCHAR(' + var.arrayElemCount.to_s + ')') if var.arrayElemCount > 0

          return('VARCHAR(MAX)')

        elsif var.vtype == 'StringUNC16'
          return('NTEXT') if var.arrayElemCount > 9999

          return('NVARCHAR(' + var.arrayElemCount + ')')

        end
      elsif var.hasOneToOneRelation
        refClass = ClassModelManager.findVarClass(var)
        if !refClass.nil?
          return @langProfile.getTypeName(refClass.model.getIdentityVar.vtype)
        end
      end

      return @langProfile.getTypeName(var.vtype)
    end

    # Get the extension for a file type
    def getExtension(eType)
      return @langProfile.getExtension(eType)
    end

    # Returns the version of this name styled for this language
    def get_styled_variable_name(var, prefix = '')
      if prefix.nil?
        prefix = ''
      end
      return CodeNameStyling.getStyled(prefix + var.name, @langProfile.variableNameStyle)
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def getComment(var)
      return '/* ' << var.text << " */\n"
    end
  end
end
