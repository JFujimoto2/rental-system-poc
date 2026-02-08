class CreateContractRenewals < ActiveRecord::Migration[8.1]
  def change
    create_table :contract_renewals do |t|
      t.references :contract, null: false, foreign_key: true
      t.references :new_contract, foreign_key: { to_table: :contracts }
      t.integer :status
      t.date :renewal_date
      t.integer :current_rent
      t.integer :proposed_rent
      t.integer :renewal_fee
      t.date :tenant_notified_on
      t.text :notes

      t.timestamps
    end
  end
end
