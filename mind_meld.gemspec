Gem::Specification.new do |s|
  s.name = 'mind_meld'
  s.version = '0.0.6'
  s.date = Time.now.strftime("%Y-%m-%d")
  s.summary = 'API for Hive Mind'
  s.description = 'API for Hive Mind'
  s.author = ['Joe Haig']
  s.email = ['joe.haig@bbc.co.uk']
  s.files = Dir['README.md', 'lib/**/*.rb']
  s.homepage = 'https://github.org/bbc/mind_meld'
  s.license = 'MIT'
  s.add_runtime_dependency 'activesupport', '~> 4'
  s.add_development_dependency 'rspec', '~> 3.3'
  s.add_development_dependency 'webmock', '~> 1.21'
end
