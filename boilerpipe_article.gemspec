Gem::Specification.new do |s|
  s.name        = 'BoilerpipeArticle'
  s.add_runtime_dependency "nokogiri", ["= 1.6.8"]
  s.required_ruby_version = '>= 1.9'
  s.version     = '0.0.2'
  s.licenses    = ['MIT']
  s.summary     = "This gem extract the main textual content of a HTML page (e.g. news articles)."
  s.description = "This gem removes the surplus “clutter” (boilerplate, templates) around the main textual content of a web page (pure Ruby implementation). Check GitHub for usage examples."
  s.authors     = ["David Layer-Reiss"]
  s.email       = 'layerreiss@gmail.com'
  s.files       = ["lib/boilerpipe_article.rb"]
  s.homepage    = 'https://github.com/davidlr99/BoilerpipeArticle'
end
