class CreateDeletedTaggings < ActiveRecord::Migration
  def change
    create_table :deleted_taggings do |t|
      t.integer :source_filter_id
      t.string :source_filter_type
      t.text :deleted_tagging
      t.timestamps
    end
  end
end
