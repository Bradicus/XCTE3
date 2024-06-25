require "managers/name_compare"

class ClassTypeManager
  @@types = Hash.new

  def self.types
    return @@types
  end

  def add_type(lang_name, cls_spec, cls_plugin)
    newType = CodeElemClassRef.new(nil, nil)
    newType.type_name = cls_plugin.get_unformatted_class_name(cls_spec)

    @@types[lang_name] < 
  end

  def self.find_class_type_by_name(type_name)
  end
end
