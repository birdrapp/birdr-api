class CreateSightings < ActiveRecord::Migration[5.1]
  def change
    create_table :sightings, id: :uuid do |t|
      t.references :bird, type: :uuid, foreign_key: true, null: false
      t.references :user, type: :uuid, foreign_key: true, null: false

      t.timestamps
    end

    add_index :sightings, [:user_id, :bird_id], unique: true
  end
end
