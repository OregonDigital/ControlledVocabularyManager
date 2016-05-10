class AddInstitutionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :institution, :string
  end
end
