#Encoding: UTF-8

require 'nokogiri'
require 'mida'

class BoilerpipeArticle
  def initialize(html)
    @html = html.gsub(/\s\s+/,' ')
    @articlesStats = Hash.new
  end
  def removeBadHtmlTags(html = @html)
    html =  Nokogiri::HTML.parse(html).to_s
    html.gsub!(/<!-[\s\S]*?->/, '')
    html.gsub!(/\r?\n|\r/, '')

    unwantedTags = ['strong','bold','i']
    unwantedTags.each do |tag|
      html.gsub!("<#{tag}>",'')
      html.gsub!("</#{tag}>",'')
    end


    doc = Nokogiri::HTML(html)

    badHtmlTags = ['script','style','head','nav','iframe','img','footer','ol','ul','li','a']
    doc.css('*').each do |node|
      node.remove if node.text.length < 3
    end
    badHtmlTags.each do |tag|
      doc.search(tag).each do |src|
        src.remove
      end
    end
    # doc.css('a').each do |atag|
    #   atag = "#{atag.text}"
    #   puts atag
    # end
    html = doc.to_html.to_s

    return html
  end
  def calculateDepth(html = @html)
    articlesStats = Hash.new
    doc = Nokogiri::HTML(html)
    i = 0
    doc.xpath('//text()').each do |node|
      text = node.to_s
      articlesStats.store(i,[node.text.to_s,node.ancestors.length.to_i,node.parent.name])
      i+=1
    end
    return articlesStats
  end
  def removeSamePatterns(html)
    doc = Nokogiri::HTML(html)
    paths = Array.new
    doc.css('*').each do |node|
      s = node.path.gsub(/\[[\s\S]*?\]/, '')
      paths.push(s)
    end
    final = []
    (7..30).each do |i|
      all = []
      paths.each_with_index do |seq,a|
        se = []
        paths[a..-1].each_with_index do |s,ii|
          se << s
          break if ii == i-1
        end
        all << se
      end
      final << all
    end
    allDoubles = Hash.new
    final.each_with_index do |seq,i|
      counts = Hash.new(0)
      seq.each do |name|
        counts[name] += 1
      end
      counts = counts.sort_by{|k,v|v}.reverse.to_h
      allDoubles.store(i,counts)
    end
    allDoubles.each do |i,doubles|
      doubles.each do |path,count|
        if count >= 7
          doc.css('*').each do |node|
            s = node.path.gsub(/\[[\s\S]*?\]/, '')
            if path.include? s
              node.remove
            end
          end
        end
      end
    end
    return doc.to_s
  end
  def calculateBestDepth(articlesStats)
    bestDepth = Hash.new(0)
    articlesStats.each do |line,stats|
      bestDepth[stats[1]]+=stats[0].length
    end
    bestvalues = bestDepth.sort_by {|key,value|value}.reverse.to_h
    average = 0.0
    bestDepth.each {|l,v|average+=v/bestDepth.keys.length.to_f}
    texts = 0
    bestDepth.each{|l,v|texts +=1 if v > average}

    doubleTexts = false
    doubleTexts = true if texts >= 2
    best = bestvalues.keys[0]

    return best,doubleTexts
  end

  def getTextOfBestDepth(articlesStats,best)
    text = ''
    articlesStats.each do |line,stats|
      if stats[1] == best && (stats[-1].eql?('h1') || stats[-1].eql?('h2') || stats[-1].eql?('p'))
        text = "#{text} <#{stats[-1]}>#{stats[0]}</#{stats[-1]}>" if stats[0].strip.length > 2
      end
    end
    return text
  end

  def getMetas(html = @html)
    metas = Hash.new
    doc = Nokogiri.parse(html)
    doc.xpath("//meta").each do |node|
      name = node[node.attributes.keys[1]]
      name = node[node.attributes.keys[0]] if node.attributes.keys[0] != 'content' &&  node.attributes.keys[0] != 'value'
      content = node['content']
      content = node['value'] if content == nil

      metas.store(name,content)
    end
    return metas
  end
  def getOtherHTMLDescriptions(html = @html)
    doc = Nokogiri.parse(html)
    images = Array.new
    headlines = Hash.new
    links = Hash.new
    5.times do |i|
      hs = doc.xpath("//h#{i+1}")
      texts = []
      hs.each {|node| texts.push(node.text.to_s)}
      headlines.store("h#{i+1}",texts)
    end

    imgs = doc.xpath('//img/@src')
    imgs.each do |source|
      images.push(source.text) if source.text.include?('http')
    end

    plinks = doc.xpath('//a/@href')
    plinks.each do |source|
      links.store(source.text,1) if source.text.strip.length > 2
    end

    return {'headlines'=>headlines,'images'=>images, 'links' => links.keys}
  end
  def getMicroData(html = @html)
    doc = Mida::Document.new(html, "")
    topLevel = Array.new
    doc.items.each do |item|
      topLevel.push(item.to_h)
    end
    return topLevel
  end
  def getAllText(html = @html)
    doc = Nokogiri.parse(html)
    doc.search('script').remove
    doc.search('style').remove
    return doc.text.gsub(/\s\s+/,' ')
  end
  def getArticle(html = @html)
    html = removeBadHtmlTags(html)
    articlesStats = calculateDepth(html)
    best,doubleTexts = calculateBestDepth(articlesStats)
    if doubleTexts
      html = removeSamePatterns(html)
      articlesStats,d = calculateDepth(html)

    end
    bestDepth,doubles = calculateBestDepth(articlesStats)
    plainText = getTextOfBestDepth(articlesStats,bestDepth)
    return plainText
  end

end
