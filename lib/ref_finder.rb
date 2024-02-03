require 'class_and_plug'
require 'managers/name_compare'

class RefFinder
  def self.find_class_by_type(lang, uType)
    cap = ClassAndPlug.new

    for cls in ClassModelManager.list
      XCTEPlugin.getLanguages[lang].each do |_plugKey, plug|
        if NameCompare.matches(plug.name, cls.plug_name) && NameCompare.matches(plug.get_unformatted_class_name(cls), uType)
          cap.cls = cls
          cap.plug = plug

          return cap
        end
      end
    end

    nil
  end
end
