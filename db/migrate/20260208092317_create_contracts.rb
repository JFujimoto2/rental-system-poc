class CreateContracts < ActiveRecord::Migration[8.1]
  def change
    create_table :contracts do |t|
      t.references :room, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true
      t.references :master_lease, foreign_key: true
      t.integer :lease_type
      t.date :start_date
      t.date :end_date
      t.integer :rent
      t.integer :management_fee
      t.integer :deposit
      t.integer :key_money
      t.integer :renewal_fee
      t.integer :status
      t.text :notes

      t.timestamps
    end
  end
end
