class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :space, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end
    
    add_index :bookings, :status
    add_index :bookings, [:start_time, :end_time]
  end
end
