class AddRolesToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :role, :string
  end
end
