Gem::Specification.new do |s|
  s.name        = 'msfl_visitors'
  s.version     = '1.0.0'
  s.date        = '2015-05-27'
  s.summary     = "Convert MSFL to other forms"
  s.description = "Visitor pattern approach to converting MSFL to other forms."
  s.authors     = ["Courtland Caldwell"]
  s.email       = 'courtland@mattermark.com'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.homepage    =
      'https://github.com/Referly/msfl_visitors'
  s.add_runtime_dependency "msfl", "~> 1.2", ">=1.2.1"
  s.add_development_dependency "rake", "~> 10.3"
  s.add_development_dependency "simplecov", "~> 0.10"
  s.add_development_dependency "yard", "~> 0.8"
  s.add_development_dependency "rspec", "~> 3.2"
  s.add_development_dependency "byebug", "~> 4.0"
  s.license     = "MIT"
end