Gem::Specification.new do |s|
  s.name        = 'msfl-visitors'
  s.version     = '0.0.1'
  s.date        = '2015-05-01'
  s.summary     = "Convert MSFL to other forms"
  s.description = "Visitor pattern approach to converting MSFL to other forms."
  s.authors     = ["Courtland Caldwell"]
  s.email       = 'courtland@mattermark.com'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.homepage    =
      'https://github.com/Referly/msfl-visitors'
  # s.add_runtime_dependency "json", "~> 1.7"
  # s.add_development_dependency "rake", "~> 10.3"
  # s.add_development_dependency "simplecov", "~> 0.9"
  # s.add_development_dependency "yard", "~> 0.8"
  # s.add_development_dependency "rspec", "~> 3.1"
  # s.add_development_dependency "byebug", "~> 3.5"
  s.license     = "MIT"
end