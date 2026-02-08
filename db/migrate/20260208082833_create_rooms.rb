class CreateRooms < ActiveRecord::Migration[8.1]
  def change
    create_table :rooms do |t|
      t.references :building, null: false, foreign_key: true
      t.string :room_number
      t.integer :floor
      t.decimal :area
      t.integer :rent
      t.integer :status
      t.string :room_type
      t.text :notes

      t.timestamps
    end
  end
end
