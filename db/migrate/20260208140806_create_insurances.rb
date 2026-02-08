class CreateInsurances < ActiveRecord::Migration[8.1]
  def change
    create_table :insurances do |t|
      t.references :building, foreign_key: true
      t.references :room, foreign_key: true
      t.integer :insurance_type
      t.integer :status
      t.string :policy_number
      t.string :provider
      t.integer :coverage_amount
      t.integer :premium
      t.date :start_date
      t.date :end_date
      t.text :notes

      t.timestamps
    end
  end
end
