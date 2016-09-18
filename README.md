# BoilerpipeArticle
<<<<<<< HEAD
This gem removes the surplus “clutter” (boilerplate, templates) around
the main textual content of a web page (pure Ruby implementation). It's especially made for news websites content. It's also able to extract schema.org microdata and other HTML meta data.
=======
This gem removes the surplus “clutter” (boilerplate, templates) around 
the main textual content of a web page (pure Ruby implementation). It's especially made for news websites content and can be also used as open graph meta parser.
>>>>>>> origin/master

##Installation
```
gem install BoilerpipeArticle
```

###Usage Example

```ruby
require 'boilerpipe_article'
require 'net/http'


<<<<<<< HEAD
uri = URI('http://www.bbc.com/news/election-us-2016-36935175')
html = Net::HTTP.get(uri)

parser =  BoilerpipeArticle.new(html)

articleText = parser.getArticle
metas = parser.getMetas
microdata = parser.getMicroData
allText  = parser.getAllText

puts articleText
puts metas
puts microdata
=======
uri = URI('http://www.bbc.com/news/business-36854285')
html = Net::HTTP.get(uri)

parser =  BoilerpipeArticle.new(html)
plaintext = parser.getText
ogmetas = parser.getOgMetas

puts plaintext
puts ogmetas.to_s
>>>>>>> origin/master
```


#### Runtime Dependencies:
nokogiri = 1.6.8
mida = 0.3.9
