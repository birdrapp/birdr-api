class CreateTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :tokens, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true, null: false

      t.timestamps
    end
  end
end
