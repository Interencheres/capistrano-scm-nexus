$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "capistrano_scm_nexus/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "capistrano_scm_nexus"
  s.version = CapistranoSCMNexus::VERSION
  s.authors = ["Interencheres (forked from Jen Page)"]
  s.email = ["dt@cpmultimedia.com"]
  s.homepage = "https://github.com/Interencheres/capistrano-scm-nexus"
  s.license = 'MIT'
  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]
  s.add_dependency "capistrano"
end
