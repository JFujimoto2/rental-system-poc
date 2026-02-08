class CreateTenantPayments < ActiveRecord::Migration[8.1]
  def change
    create_table :tenant_payments do |t|
      t.references :contract, null: false, foreign_key: true
      t.date :due_date
      t.integer :amount
      t.integer :paid_amount
      t.date :paid_date
      t.integer :status
      t.integer :payment_method
      t.text :notes

      t.timestamps
    end
  end
end
