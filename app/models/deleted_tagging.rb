class DeletedTagging < ActiveRecord::Base
  attr_accessible :deleted_tagging
  serialize :deleted_tagging
  belongs_to :source_filter, :polymorphic => true
end
