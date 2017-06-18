class AddPasswordToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :password_digest, :binary, limit: 60, null: false
  end
end
