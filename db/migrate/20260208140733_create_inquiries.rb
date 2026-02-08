class CreateInquiries < ActiveRecord::Migration[8.1]
  def change
    create_table :inquiries do |t|
      t.references :room, foreign_key: true
      t.references :tenant, foreign_key: true
      t.references :assigned_user, foreign_key: { to_table: :users }
      t.references :construction, foreign_key: true
      t.integer :category
      t.integer :priority
      t.integer :status
      t.string :title
      t.text :description
      t.text :response
      t.date :received_on
      t.date :resolved_on
      t.text :notes

      t.timestamps
    end
  end
end
