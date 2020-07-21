class AddInstitutionToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :institution, :string
  end
end
