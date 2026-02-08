class CreateOwners < ActiveRecord::Migration[8.1]
  def change
    create_table :owners do |t|
      t.string :name
      t.string :name_kana
      t.string :phone
      t.string :email
      t.string :postal_code
      t.string :address
      t.string :bank_name
      t.string :bank_branch
      t.string :account_type
      t.string :account_number
      t.string :account_holder
      t.text :notes

      t.timestamps
    end
  end
end
