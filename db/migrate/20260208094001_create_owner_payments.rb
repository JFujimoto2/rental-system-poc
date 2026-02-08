class CreateOwnerPayments < ActiveRecord::Migration[8.1]
  def change
    create_table :owner_payments do |t|
      t.references :master_lease, null: false, foreign_key: true
      t.date :target_month
      t.integer :guaranteed_amount
      t.integer :deduction
      t.integer :net_amount
      t.integer :status
      t.date :paid_date
      t.text :notes

      t.timestamps
    end
  end
end
