##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class loads attribute information form an XML node

require "log"

module XCTETypescript
  class ComponentConfig
    attr_accessor :imports, :declarations, :exports, :file_part, :selector_name, :standalone

    def initialize
      @imports = Array.new
      @declarations = Array.new
      @exports = Array.new
      @file_part = nil
      @selector_name = nil
      @standalone = true
    end

    def w_file_part(file_part)
      @file_part = file_part
      return self
    end

    def w_selector_name(selector_name)
      @selector_name = selector_name
      return self
    end

    def w_declarations(declarations)
      @declarations = imports
      return self
    end

    def w_imports(imports)
      @imports = imports
      return self
    end

    def w_exports(imports)
      @imports = exports
      return self
    end
  end
end
