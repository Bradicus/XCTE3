##

#
# Copyright (C) 2008 Brad Ottoson
# This file is released under the zlib/libpng license, see license.txt in the
# root directory
#
# This class stores information on the library component of a project

module CodeStructure
  class CodeElemBuildType
     attr_accessor :buildOptions, :buildType

    def initialize()
      @elementId = CodeElem::ELEM_BUILD_TYPE;

      @buildType = String.new
      @buildOptions = Array.new
    end

    def getBuildOpts(compilerName)
      optStr = String.new

      if (compilerName == "gcc")

        for bOpt in @buildOptions

          puts "processing option type: " << bOpt.oType

          case(bOpt.oType)

          when "optimize"
              if bOpt.oValue == "L2"
                optStr << "-O2 "
              end

          when "warnings"
              if bOpt.oValue == "showall"
                optStr << "-Wall "
              end

          when "profiling"
              if bOpt.oValue == "on"
                optStr << "-pg "
              end

          when "debug_info"
              if bOpt.oValue == "yes"
                optStr << "-D "
              end

          end
        end

      end

      return optStr
    end
    
  end
end
