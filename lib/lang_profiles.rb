require "lang_profile"
require "singleton"
require "log"

class LangProfiles
  include Singleton
  attr_accessor :profiles

  def load(project)
    @profiles = Hash.new

    codeRootDir = File.dirname(File.realpath(__FILE__))
    langProfileDir = codeRootDir + "/../lang_profiles"

    loadFromPath(project, langProfileDir)

    # Overwrite default profiles if there are any custom profiles from the project config
    for proPath in project.langProfilePaths
      loadFromPath(project, proPath)
    end
  end

  # Load any language profiles from the directory path
  def loadFromPath(project, path)
    # Load the default language profles
    if (File.directory?(path))
      for fileName in Dir.entries(path)
        if fileName.include?(".xml")
          langName = fileName[0..-5]

          langProfile = LangProfile.new(langName)

          filePath = path + "/" + fileName
          file = File.new filePath

          xmlDoc = REXML::Document.new file

          langProfile.load(xmlDoc)

          #puts "Loaded language " + langName + " from " + fileName

          @profiles[langName] = langProfile
        end
      end
    else
      Log.error "ERROR loadin language profile path: " + path
    end
  end
end
