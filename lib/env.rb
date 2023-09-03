class Env
  attr_accessor :codeRootDir

  @@codeRootDir = nil

  def self.getCodeRootDir
    return @@codeRootDir
  end

  def self.setCodeRootDir(newCodeRootDir)
    @@codeRootDir = newCodeRootDir
  end
end
