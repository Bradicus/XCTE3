class PathUtil
  def self.get_dependency_path(cls)
    if !cls.path.nil?
      depPath = cls.path
    else
      depPath = cls.namespace.get("/")
    end

    depPath
  end
end
