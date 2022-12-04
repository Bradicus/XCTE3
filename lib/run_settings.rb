##

#
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores user settings loaded from an XML file

require "user_settings.rb"

class RunSettings
  attr_accessor :models

  @@models = nil

  def self.setModels(models)
    @@models = models
  end
end
