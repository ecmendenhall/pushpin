class AddPinboardConfirmedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pinboard_confirmed, :boolean
  end
end
