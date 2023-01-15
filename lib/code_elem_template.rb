##
# Template element
#

module CodeStructure
  class CodeElemTemplate
    attr_accessor :name, :pointerTpl, :isCollection

    @name
    @pointerTpl = nil
    @isCollection = false

    def initialize(tplString = "")
      tplSet = tplString.split(",")

      for tpl in tplSet
        tplParts = tpl.split("#")
        @name = tplParts[0]

        if (@name.downcase == "list")
          @isCollection = true
        end

        if (tplParts.length > 1)
          specialType = tplParts[1].downcase
          if (specialType == "list" || specialType == "set")
            @isCollection = true
          elsif (specialType.start_with? "ptr")
            @pointerTpl = specialType
          end
        end
      end
    end
  end
end
