class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.string :notification_type, null: false
      t.boolean :read, null: false, default: false

      t.timestamps
    end
    
    add_index :notifications, :notification_type
    add_index :notifications, :read
  end
end
