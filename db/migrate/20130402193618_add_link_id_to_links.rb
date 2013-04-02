class AddLinkIdToLinks < ActiveRecord::Migration
  def change
    add_column :links, :link_id, :string
    add_index :links, :link_id, unique: true
  end
end
