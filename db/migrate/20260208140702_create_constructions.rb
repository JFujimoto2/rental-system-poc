class CreateConstructions < ActiveRecord::Migration[8.1]
  def change
    create_table :constructions do |t|
      t.references :room, null: false, foreign_key: true
      t.references :vendor, foreign_key: true
      t.integer :construction_type
      t.integer :status
      t.string :title
      t.text :description
      t.integer :estimated_cost
      t.integer :actual_cost
      t.date :scheduled_start_date
      t.date :scheduled_end_date
      t.date :actual_start_date
      t.date :actual_end_date
      t.integer :cost_bearer
      t.text :notes

      t.timestamps
    end
  end
end
