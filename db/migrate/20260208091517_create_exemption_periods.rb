class CreateExemptionPeriods < ActiveRecord::Migration[8.1]
  def change
    create_table :exemption_periods do |t|
      t.references :master_lease, null: false, foreign_key: true
      t.references :room, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.string :reason

      t.timestamps
    end
  end
end
