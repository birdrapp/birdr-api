class CreateBirds < ActiveRecord::Migration[5.1]
  def change
    create_table :birds, id: :uuid do |t|
      t.string     :common_name, limit: 255, null: false
      t.string :scientific_name, limit: 255, null: false
      t.integer     :sort_order, null: false

      t.timestamps
    end

    add_index :birds, :scientific_name, unique: true
    add_index :birds,      :sort_order, unique: true
  end
end
