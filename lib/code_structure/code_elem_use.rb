##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the 
# root directory
#
# This class stores information for the uses that get added to a class file
 
require 'code_structure/code_elem'

module CodeStructure
	class CodeElemUse
		attr_accessor :namespace
	  
	  def initialize(namespace)
		@namespace = namespace
	  end
	end
end
