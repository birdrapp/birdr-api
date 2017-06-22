class AddPasswordResetsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :password_reset_digest, :binary, limit: 60
    add_column :users, :password_reset_sent_at, :timestamp
  end
end
