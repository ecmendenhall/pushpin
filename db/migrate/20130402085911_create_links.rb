class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :url
      t.string :title
      t.text :description
      t.datetime :datetime
      t.integer :user_id

      t.timestamps
    end
    add_index :links, [:user_id, :created_at]
  end
end
