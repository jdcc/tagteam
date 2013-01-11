# An DeleteTagFilter lets you remove a ActsAsTaggableOn::Tag from an object via a HubTagFilter, HubFeedTagFilter or HubFeedItemTagFilter.
#
# Most validations are contained in the ModelExtensions mixin.
#
class DeleteTagFilter < ActiveRecord::Base
  include ModelExtensions
  include TagFilterExtensions
  acts_as_api do|c|
    c.allow_jsonp_callback = true
  end

  has_one :hub_tag_filter, :as => :filter
  has_one :hub_feed_tag_filter, :as => :filter
  has_one :hub_feed_item_tag_filter, :as => :filter
  has_many :deleted_taggings, :as => :source_filter

  belongs_to :relevant_tag, :class_name => 'ActsAsTaggableOn::Tag'
  attr_accessible :relevant_tag_id
  validates_presence_of :relevant_tag_id

  before_destroy :unact

  api_accessible :default do|t|
    t.add :id
    t.add :relevant_tag
  end

  def css_class
    'delete'
  end

  def description
    'Delete tag: '
  end

  # Does the actual "filtering" by removing a tag from the tag list.
  def act(feed_item)
    old_tagging = feed_item.taggings.where(
      :context => filter.hub.tagging_key,
      :tag_id => relevant_tag.id
    ).first
    if old_tagging
      deleted_taggings.create(:deleted_tagging => 
        {
          :tag_id => old_tagging.tag_id, 
          :taggable_id => old_tagging.taggable_id,
          :taggable_type => old_tagging.taggable_type,
          :tagger_id => old_tagging.tagger_id,
          :tagger_type => old_tagging.tagger_type,
          :context => old_tagging.context
        }
      )
      old_tagging.destroy
    end
  end

  def unact
    deleted_taggings.each do |deleted_tagging|
      ActsAsTaggableOn::Tagging.new(deleted_tagging.deleted_tagging).save
    end
    deleted_taggings.destroy_all
  end

  def self.title
    'Delete tag filter'
  end

end
