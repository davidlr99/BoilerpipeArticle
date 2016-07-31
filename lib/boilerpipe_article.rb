require 'nokogiri'

class BoilerpipeArticle
  def initialize(html)
    @html = html
  end

  def getText(html = @html)
    html =  Nokogiri::HTML.parse(html).to_s
    html.gsub!(/<!-[\s\S]*?->/, '')
    html.gsub!(/\r?\n|\r/, '')

    doc = Nokogiri::HTML(html)
    badHtmlTags = ['nav','head','script','style','a','img']
    badHtmlTags.each do |tag|
      doc.search(tag).each do |src|
        src.remove
      end
    end

    html = doc.to_html.to_s
    selfClosingTags = ['<area','<base','<br','<col','<command','<embed','<hr','<img','<input','<keygen','<link','<meta','<param','<source','<track','<wbr']
    time = Time.now.to_f
    depth = 1
    i = 0
    start = 0
    close = 0
    articlesStats = Hash.new
    inPtag = false
    content = ''
    html.length.times do
      char = html[i]
      if char.eql? '<'
        start = i
        ii = start
        html.length.times do
          char2 = html[ii]
          if char2.eql? '>'
            tag = html[start..ii]
            tagname = "#{tag}"
            inPtag = true if tagname.eql?('<p>') || tagname.split(' ')[0].eql?('<p')
            content = html[close..start].gsub(/[<>]/,'')
            tagname = "#{tag}"
            text = ''
            text = content if inPtag
            articlesStats.store(i,[text,depth,tagname]) if content.gsub(/[^a-zA-Z]+/,'').length > 1
            close = ii
            inPtag = false if tagname.eql? '</p>'
            if !selfClosingTags.include?(tag.split(" ")[0]) && !tag.include?('<br')
              tag.gsub!(/"[\s\S]*?"/,'')
              tag.gsub!(/[^<>\/]+/,'')
              if tag.eql? '<>'
                depth+=1
              else
                depth-=1
              end
            end
            break
          end
          ii+=1
        end
      end
      i+=1
    end
    bestDepth = Hash.new(0)
    articlesStats.each do |line,stats|
      bestDepth[stats[1]]+=stats[0].gsub(/[^a-zA-Z]+/,'').length
    end
    best = bestDepth.sort_by {|key,value|value}.reverse.to_h.keys[0]
    text = ''
    articlesStats.each do |line,stats|
      text = "#{text} #{stats[0]}" if stats[1] == best
    end
    return Nokogiri::HTML.parse(text).text
  end

  def getOgMetas(html = @html)
    metas = Hash.new
    doc = Nokogiri.parse(html)
    properties = ['title','type','url','description','image','type','updated_time','locale','url','site_name']
    properties.each do |prop|
      if doc.at("meta[property=\"og:#{prop}\"]") != nil
        metas.store(prop,doc.at("meta[property=\"og:#{prop}\"]")['content'])
      else
        metas.store(prop,' ')
      end
    end
    return metas
  end
end
