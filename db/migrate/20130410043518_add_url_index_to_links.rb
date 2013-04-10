class AddUrlIndexToLinks < ActiveRecord::Migration
    add_index :links, [:url]
end
