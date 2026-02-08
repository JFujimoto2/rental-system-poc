class CreateKeys < ActiveRecord::Migration[8.1]
  def change
    create_table :keys do |t|
      t.references :room, null: false, foreign_key: true
      t.integer :key_type
      t.string :key_number
      t.integer :status
      t.text :notes

      t.timestamps
    end
  end
end
