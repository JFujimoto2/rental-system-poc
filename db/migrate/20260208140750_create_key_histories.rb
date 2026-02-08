class CreateKeyHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :key_histories do |t|
      t.references :key, null: false, foreign_key: true
      t.references :tenant, foreign_key: true
      t.integer :action
      t.date :acted_on
      t.text :notes

      t.timestamps
    end
  end
end
