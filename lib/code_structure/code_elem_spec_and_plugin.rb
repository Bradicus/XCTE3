##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

module CodeStructure
  class CodeElemSpecAndPlugin
    attr_accessor :spec, :plugin, :type_name

    @spec = nil
    @plugin = nil
    @type_name = nil

    def valid?
      return !@spec.nil? && !@plugin.nil?
    end
  end
end
