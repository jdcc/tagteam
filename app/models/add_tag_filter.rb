# An AddTagFilter lets you add a ActsAsTaggableOn::Tag to an object via a HubTagFilter, HubFeedTagFilter or HubFeedItemTagFilter.
# 
# Most validations are contained in the ModelExtensions mixin.
#
class AddTagFilter < ActiveRecord::Base
  include ModelExtensions
  include TagFilterExtensions
  acts_as_api do|c|
    c.allow_jsonp_callback = true
  end

  has_one :hub_tag_filter, :as => :filter
  has_one :hub_feed_tag_filter, :as => :filter
  has_one :hub_feed_item_tag_filter, :as => :filter

  belongs_to :relevant_tag, :class_name => 'ActsAsTaggableOn::Tag'
  validates_presence_of :relevant_tag_id
  attr_accessible :relevant_tag_id

  before_destroy :unact
  acts_as_tagger

  api_accessible :default do|t|
    t.add :id
    t.add :relevant_tag_id
  end

  def description
    'Add tag: '
  end

  def css_class
    'add'
  end

  # Does the actual "filtering" by appending itself into the tag list.
  def act(feed_item)
    self.tag(feed_item, :on => filter.hub.tagging_key, :with => relevant_tag.name)
  end

  def unact
    self.owned_taggings.destroy_all
  end

  def self.title
    'Add tag filter'
  end

end
