class AddOwnerToBuildings < ActiveRecord::Migration[8.1]
  def change
    add_reference :buildings, :owner, foreign_key: true
  end
end
