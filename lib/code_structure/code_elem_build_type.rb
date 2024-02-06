##
# Copyright XCTE Contributors
# This file is released under the zlib/libpng license, see license.txt in the
# root directory

module CodeStructure
  class CodeElemBuildType
     attr_accessor :buildOptions, :buildType

    def initialize()
      @element_id = CodeStructure::CodeElemTypes::ELEM_BUILD_TYPE;

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
