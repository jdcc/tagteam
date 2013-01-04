xml.instruct! :xml, :version => "1.0" 
xml.rss(
  :version => '2.0',
  'xmlns:content' => 'http://purl.org/rss/1.0/modules/content/',
  'xmlns:dc' => 'http://purl.org/dc/elements/1.1/'
  ) do
  xml.channel do
    xml.title @hub.title
    xml.description @hub.description
    xml.link hub_url(@hub)
    xml.generator Tagteam::Application.config.rss_generator

    @search.results.each do |item|
      xml.item do
        xml.title item.title
        unless item.description.blank?
          xml.description item.description
        end
        unless item.content.blank?
          xml.tag!('content:encoded', item.content)
        end
        unless item.date_published.blank?
          xml.pubDate item.date_published.to_s(:rfc822)
        end
        xml.link item.url
        xml.guid item.guid
        xml.author item.authors
        item.owner_tags_on(nil, @hub.tagging_key).each do|tag|
          xml.category (@hub.tag_prefix.blank?) ? tag.name : tag.name_prefixed_with(@hub.tag_prefix)
        end
        unless item.rights.blank?
          xml.tag!('dc:rights', item.rights)
        end
        unless item.contributors.blank?
          xml.tag!('dc:contributor', item.contributors)
        end
      end
    end
  end
end
