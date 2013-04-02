class AddPinboardToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pinboard, :string
    add_index :users, :pinboard
  end
end
