require 'name_compare'
require 'class_and_plug'

class RefFinder
  def self.find_class_by_type(lang, uType)
    cap = ClassAndPlug.new

    for cls in ClassModelManager.list
      XCTEPlugin.getLanguages[lang].each do |_plugKey, plug|
        if NameCompare.same(plug.name, cls.plugName) && NameCompare.same(plug.get_unformatted_class_name(cls), uType)
          cap.cls = cls
          cap.plug = plug

          return cap
        end
      end
    end

    nil
  end
end
