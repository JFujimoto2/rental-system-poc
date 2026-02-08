class CreateSettlements < ActiveRecord::Migration[8.1]
  def change
    create_table :settlements do |t|
      t.references :contract, null: false, foreign_key: true
      t.integer :settlement_type
      t.date :termination_date
      t.integer :daily_rent
      t.integer :days_count
      t.integer :prorated_rent
      t.integer :deposit_amount
      t.integer :restoration_cost
      t.integer :other_deductions
      t.integer :refund_amount
      t.integer :status
      t.text :notes

      t.timestamps
    end
  end
end
