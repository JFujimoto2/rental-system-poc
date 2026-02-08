class CreateApprovals < ActiveRecord::Migration[8.1]
  def change
    create_table :approvals do |t|
      t.references :approvable, polymorphic: true, null: false
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :approver, null: true, foreign_key: { to_table: :users }
      t.integer :status, default: 0, null: false
      t.datetime :requested_at
      t.datetime :decided_at
      t.text :comment

      t.timestamps
    end
  end
end
