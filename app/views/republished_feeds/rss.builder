xml.instruct! :xml, :version => "1.0" 
xml.rss(
  :version => '2.0',
  'xmlns:content' => 'http://purl.org/rss/1.0/modules/content/',
  'xmlns:dc' => 'http://purl.org/dc/elements/1.1/'
  ) do
  xml.channel do
    xml.title @republished_feed.title
    xml.description @republished_feed.description
    xml.link republished_feed_url(@republished_feed)
    xml.generator RSS_GENERATOR

    @republished_feed.items.each do |item|
      xml.item do
        xml.title item.title
        unless item.description.blank?
          xml.description item.description
        end
        unless item.content.blank?
          xml.send('content:encoded', item.content) 
        end
        unless item.date_published.blank?
          xml.pubDate item.date_published.to_s(:rfc822)
        end
        xml.link item.url
        xml.guid item.guid
        xml.author item.authors
        item.feed_item_tags.each do|fit|
          xml.category fit.tag
        end
        unless item.rights.blank?
          xml.send('dc:rights', item.rights)
        end
        unless item.contributors.blank?
          xml.send('dc:contributor', item.contributors)
        end
      end
    end
  end
end