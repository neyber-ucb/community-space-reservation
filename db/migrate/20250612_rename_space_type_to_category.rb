class RenameSpaceTypeToCategory < ActiveRecord::Migration[8.0]
  def change
    rename_column :spaces, :space_type, :category
  end
end
