class CreateVendors < ActiveRecord::Migration[8.1]
  def change
    create_table :vendors do |t|
      t.string :name
      t.string :phone
      t.string :email
      t.string :address
      t.string :contact_person
      t.text :notes

      t.timestamps
    end
  end
end
