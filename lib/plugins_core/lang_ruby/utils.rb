##
# @author Brad Ottoson
#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class contains utility functions for a language

require 'lang_profile.rb'

module XCTERuby
  class Utils
    @@langProfile = LangProfile.new

    def self.init
      @@langProfile.name = "ruby"
      @@langProfile.loadProfile
    end

    # Get a parameter declaration for a method parameter
    def self.getParamDec(var)
      pDec = String.new

      pDec << getTypeName(var.vtype);

      pDec << " " << var.name;

      return pDec
    end

    # Returns variable declaration for the specified variable
    def self.getVarDec(var)
      vDec = String.new

      if var.isStatic
        vDec << "@"
      end

      vDec << "@" << var.name;

      if var.arrayElemCount.to_i > 0
        vDec << " = Array.new(" << getSizeConst(var) << ")"
      end

      if var.comment != nil
        vDec << "\t# " << var.comment;
      end

      vDec << "\n";

      return vDec
    end

    # Returns a size constant for the specified variable
    def self.getSizeConst(var)
      return "ARRAYSZ_" << var.name.upcase
    end

    # Get a parameter declaration for a method parameter
    def self.getTypeName(gType)
      return @@langProfile.getTypeName(gType)
    end

    # Get the extension for a file type
    def self.getExtension(eType)
      return @@langProfile.getExtension(eType)
    end

    # These are comments declaired in the COMMENT element,
    # not the comment atribute of a variable
    def self.getComment(var)
      return "# " << var.text << " \n"
    end

    def self.isPrimitive(var)
      return @@langProfile.isPrimitive(var)
    end
  end
end
