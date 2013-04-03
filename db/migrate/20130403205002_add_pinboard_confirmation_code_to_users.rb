class AddPinboardConfirmationCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pinboard_confirmation_code, :string
  end
end
