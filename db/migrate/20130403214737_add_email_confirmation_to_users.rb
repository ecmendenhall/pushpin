class AddEmailConfirmationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_confirmation_code, :string
    add_column :users, :email_confirmed, :boolean
  end
end
