class RenameFilterTagAssociations < ActiveRecord::Migration
  def change
    rename_column :add_tag_filters, :tag_id, :relevant_tag_id
    rename_column :modify_tag_filters, :tag_id, :relevant_tag_id
    rename_column :delete_tag_filters, :tag_id, :relevant_tag_id
  end
end
