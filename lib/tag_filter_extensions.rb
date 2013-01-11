module TagFilterExtensions
  def filter
    return hub_tag_filter if hub_tag_filter
    return hub_feed_tag_filter if hub_feed_tag_filter
    return hub_feed_item_tag_filter if hub_feed_item_tag_filter
  end
end
