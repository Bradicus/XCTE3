require "managers/name_compare"
require "managers/lang_class_types"
require "code_structure/code_elem_spec_and_plugin"

class ClassTypeManager
  @@types = Hash.new

  def self.types
    return @@types
  end

  def self.add_type(lang_name, cls_spec, cls_plugin)
    newType = CodeStructure::CodeElemSpecAndPlugin.new
    newType.type_name = cls_plugin.get_unformatted_class_name(cls_spec)
    newType.spec = cls_spec
    newType.plugin = cls_plugin

    if !@@types.key?(lang_name)
      @@types[lang_name] = LangClassTypes.new
    end

    if newType.type_name != nil
      @@types[lang_name].add_type(newType)
    end
  end

  def self.find_class_type_by_name(lang_name, type_name)
    if @@types.key?(lang_name)
      @@types[lang_name].find_class_type(type_name)
    end

    return nil
  end
end
