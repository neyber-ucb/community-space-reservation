class CreateSpaces < ActiveRecord::Migration[8.0]
  def change
    create_table :spaces do |t|
      t.string :name, null: false
      t.text :description
      t.integer :capacity, null: false
      t.string :space_type, null: false

      t.timestamps
    end

    add_index :spaces, :space_type
  end
end
