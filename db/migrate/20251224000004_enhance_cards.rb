class EnhanceCards < ActiveRecord::Migration[8.0]
  def change
    # Note: board_id already exists in Fizzy schema (db/schema.rb)
    add_reference :cards, :assigned_to, foreign_key: { to_table: :users }
    add_column :cards, :position, :integer, null: false, default: 0

    add_index :cards, [:column_id, :position]
  end
end
