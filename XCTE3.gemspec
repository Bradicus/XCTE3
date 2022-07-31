Gem::Specification.new do |s|
  s.name = "XCTE3"
  s.version = "3.0.0.rc1"
  s.summary = "Xml Code Template Engine 3"
  s.date = "2022-07-31"
  s.description = "This program creates code files in various languages based off of user defined xml files."
  s.authors = ["Brad Ottoson"]
  s.email = [""]
  s.license = "Zlib"
  s.homepage = "https://github.com/Bradicus/XCTE3"
  s.executable = "xcte3"

  s.files = Dir['bin/*.rb', 'lib/**/*.rb', 'lang_profiles/**/*.xml', 'library_profiles/**/*.xml', 'license.txt', 'default_settings_example.xml'] 
end
