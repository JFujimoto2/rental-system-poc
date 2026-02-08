class CreateTenants < ActiveRecord::Migration[8.1]
  def change
    create_table :tenants do |t|
      t.string :name
      t.string :name_kana
      t.string :phone
      t.string :email
      t.string :postal_code
      t.string :address
      t.string :emergency_contact
      t.text :notes

      t.timestamps
    end
  end
end
