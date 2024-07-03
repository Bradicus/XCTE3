class LangClassTypes
  def initialize()
    @types = Hash.new
  end

  def add_type(sap)
    @types[sap.type_name] = sap
  end

  def find_class_type(type_name)
    return @types[type_name]
  end
end
