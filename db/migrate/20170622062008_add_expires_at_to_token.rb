class AddExpiresAtToToken < ActiveRecord::Migration[5.1]
  def change
    add_column :tokens, :expires_at, :datetime, null: false
  end
end
