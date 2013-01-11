# Changes an ActsAsTaggableOn::Tag into another ActsAsTaggableOn::Tag, effectively renaming a tag.
# 
# Most validations are contained in the ModelExtensions mixin.
#
class ModifyTagFilter < ActiveRecord::Base
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
  belongs_to :new_tag, :class_name => 'ActsAsTaggableOn::Tag'
  validates_presence_of :relevant_tag_id, :new_tag_id
  attr_accessible :relevant_tag_id, :new_tag_id

  before_destroy :unact
  acts_as_tagger

  api_accessible :default do|t|
    t.add :id
    t.add :relevant_tag
    t.add :new_tag
  end

  validate :relevant_tag_id do
    if self.relevant_tag_id == self.new_tag_id
      self.errors.add(:new_tag_id, " can't be the same as the original tag")
    end
  end

  def description
    'Change tag '
  end

  def css_class
    'modify'
  end

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
      self.tag(feed_item, :on => filter.hub.tagging_key, :with => new_tag.name)
    end
  end

  def unact
    deleted_taggings.each do |deleted_tagging|
      ActsAsTaggableOn::Tagging.new(deleted_tagging.deleted_tagging).save
    end
    self.owned_taggings.destroy_all
    deleted_taggings.destroy_all
  end

  def self.title
    'Modify tag filter'
  end

end
