##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require 'plugins_core/lang_ruby/x_c_t_e_ruby'
require 'lang_profile'
require 'utils_base'

module XCTERuby
  class Utils < UtilsBase
    include Singleton

    def initialize
      super('ruby')
    end

    def get_class_name(var)
      return @langProfile.get_type_name(var.vtype) if !var.vtype.nil?

      return CodeNameStyling.getStyled(var.utype, @langProfile.classNameStyle)
    end

    # Get a parameter declaration for a method parameter
    def get_param_dec(var)
      pDec = String.new

      pDec << get_type_name(var)

      pDec << ' ' << var.name

      return pDec
    end

    # Returns variable declaration for the specified variable
    def get_var_dec(var)
      vDec = String.new

      vDec << '@' if var.isStatic

      vDec << '@' << get_styled_variable_name(var)

      vDec << ' = Array.new(' << get_size_const(var) << ')' if var.arrayElemCount.to_i > 0

      if !var.defaultValue.nil?
        vDec << ' = '
        if var.vtype == 'String'
          vDec << '"' << var.defaultValue << '"'
        else
          if (var.defaultValue == "null")
            vDec << 'nil'
          else
            vDec << var.defaultValue 
          end
        end
      elsif var.isList
        vDec << ' = []'
      elsif var.construct
        vDec << ' = '

        if var.nullable
          vDec << 'nil'
        elsif var.vtype == 'String'
          vDec << '""'
        elsif !is_primitive(var)
          vDec << ' = new ' + CodeNameStyling.getStyled(var.getUType, @langProfile.classNameStyle) + '()'
        else
          vDec << '0'
        end
      end

      vDec << "\t# " << var.comment if !var.comment.nil?

      return vDec
    end

    # Returns a size constant for the specified variable
    def get_size_const(var)
      return 'ARRAYSZ_' << var.name.upcase
    end

    # Get the extension for a file type
    def get_extension(eType)
      return @langProfile.get_extension(eType)
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def getComment(var)
      return '# ' << var.text << " \n"
    end

    # Get type for a class
    def getClassTypeName(cls)
      nsPrefix = ''
      nsPrefix = cls.namespaces.join('::') + '::' if cls.namespaces.hasItems?

      baseTypeName = CodeNameStyling.getStyled(cls.model_name, @langProfile.classNameStyle)
      baseTypeName = nsPrefix + baseTypeName

      return baseTypeName
    end

    def render_block_comment(str, bld)
      firstLine = true

      return unless !str.nil? && str.strip.length > 0

      bld.add '##'
      str.each_line do |line|
        if !firstLine || line.strip.length > 0
          bld.add('# ' + line.delete("\n"))
          firstLine = false
        end
      end
    end
  end
end
