class AddBoardMetadataSupport < ActiveRecord::Migration[8.0]
  def change
    # Ensure description column exists and is text type
    # Note: This migration assumes description column already exists
    # If it doesn't exist, this will fail - check schema first
    change_column :boards, :description, :text, null: false

    # Add creator reference
    add_reference :boards, :created_by, foreign_key: { to_table: :users }
  end
end
