# Contains the list of includes for a class generator


require 'code_elem_include_path.rb'

class CodeElemIncludeList
  attr_accessor :iPaths

  def initialize()
    @iPaths = Array.new
  end

  def addInclude(iPath, iName, iType)
    curPath = nil
    for i in @iPaths
      if i.path == iPath
        curPath = i
      end
    end

    if curPath == nil
      curPath = CodeElemIncludePath.new()
      @iPaths << curPath
      curPath.path = iPath
    end

    curName = nil
    for inc in curPath.includes
      if inc == iName
        curName = inc
      end
    end

    if curName == nil
      curPath.includes << CodeElemInclude.new(iName, iType)
    end
  end

end