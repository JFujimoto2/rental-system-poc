class CreateRentRevisions < ActiveRecord::Migration[8.1]
  def change
    create_table :rent_revisions do |t|
      t.references :master_lease, null: false, foreign_key: true
      t.date :revision_date
      t.integer :old_rent
      t.integer :new_rent
      t.text :notes

      t.timestamps
    end
  end
end
