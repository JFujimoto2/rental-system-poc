class CreateBuildings < ActiveRecord::Migration[8.1]
  def change
    create_table :buildings do |t|
      t.string :name
      t.string :address
      t.string :building_type
      t.integer :floors
      t.integer :built_year
      t.string :nearest_station
      t.text :notes

      t.timestamps
    end
  end
end
