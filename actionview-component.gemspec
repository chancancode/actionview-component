$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "actionview-component"
  s.version     = "0.1.0"
  s.authors     = ["Godfrey Chan"]
  s.email       = ["godfreykfc@gmail.com"]
  s.homepage    = "http://github.com/chancancode/actionview-component"
  s.summary     = "ActionView::Component"
  s.license     = "MIT"

  s.files = Dir["{lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "actionview", "~> 5.0.1"
  s.add_dependency "railties", "~> 5.0.1"

  s.add_development_dependency "rails", "~> 5.0.1"
  s.add_development_dependency "sqlite3"
end
