spec = Gem::Specification.new do |s| 
  s.name = "Bats!"
  s.version = "0.0.4"
  s.author = "Hans Oksendahl"
  s.email = "hansoksendahl@gmail.com"
  s.homepage = "http://hansoksendahl.com/bats"
  s.platform = Gem::Platform::RUBY
  s.summary = "A microframework built on Rack."
  s.files = ::Dir["lib/**/*"]
  s.require_path = "lib"
  s.has_rdoc = false
  s.extra_rdoc_files = ["README"]
  s.add_dependency("rack")
end
