class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string      :first_name, limit: 255, null: false
      t.string       :last_name, limit: 255, null: false
      t.string           :email, limit: 255, null: false

      t.timestamps
    end
  end
end
