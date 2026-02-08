class CreateMasterLeases < ActiveRecord::Migration[8.1]
  def change
    create_table :master_leases do |t|
      t.references :owner, null: false, foreign_key: true
      t.references :building, null: false, foreign_key: true
      t.integer :contract_type
      t.date :start_date
      t.date :end_date
      t.integer :guaranteed_rent
      t.decimal :management_fee_rate
      t.integer :rent_review_cycle
      t.integer :status
      t.text :notes

      t.timestamps
    end
  end
end
