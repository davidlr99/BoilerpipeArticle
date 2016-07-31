# BoilerpipeArticle
This gem removes the surplus “clutter” (boilerplate, templates) around 
the main textual content of a web page (pure Ruby implementation). It's especially made for news websites content and can be also used as open graph meta parser.

##Installation 
```
gem install BoilerpipeArticle
```

###Usage Example 

```ruby
require 'boilerpipe_article'
require 'net/http'


uri = URI('http://www.bbc.com/news/business-36854285')
html = Net::HTTP.get(uri)

parser =  BoilerpipeArticle.new(html)
plaintext = parser.getText
ogmetas = parser.getOgMetas

puts plaintext
puts ogmetas.to_s
```

